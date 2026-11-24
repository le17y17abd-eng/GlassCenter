#import "GCNowPlaying.h"
#import "GCGlass.h"
#import <dlfcn.h>

static void (*MRGetInfo)(dispatch_queue_t, void (^)(CFDictionaryRef));
static void (*MRGetPlaying)(dispatch_queue_t, void (^)(Boolean));
static Boolean (*MRSend)(int, id);

static void GCMRLoad(void) {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        void *h = dlopen("/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote", RTLD_LAZY);
        if (!h) return;
        MRGetInfo    = dlsym(h, "MRMediaRemoteGetNowPlayingInfo");
        MRGetPlaying = dlsym(h, "MRMediaRemoteGetNowPlayingApplicationIsPlaying");
        MRSend       = dlsym(h, "MRMediaRemoteSendCommand");
    });
}

enum { GCMRTogglePlayPause = 2, GCMRNextTrack = 4, GCMRPreviousTrack = 5 };

@implementation GCNowPlayingView {
    UIImageView *_art;
    UILabel *_title, *_artist;
    UIButton *_play;
}

- (instancetype)initWithFrame:(CGRect)f {
    if ((self = [super initWithFrame:f])) {
        GCMRLoad();
        [self addSubview:GCMakeGlass(self.bounds, 32)];
        CGFloat w = f.size.width, h = f.size.height;

        _art = [[UIImageView alloc] initWithFrame:CGRectMake(14, 14, 44, 44)];
        _art.layer.cornerRadius = 10;
        _art.layer.cornerCurve = kCACornerCurveContinuous;
        _art.clipsToBounds = YES;
        _art.backgroundColor = [UIColor colorWithWhite:1 alpha:0.14];
        _art.contentMode = UIViewContentModeScaleAspectFill;
        _art.tintColor = [UIColor colorWithWhite:1 alpha:0.7];
        _art.image = [UIImage systemImageNamed:@"music.note"];
        [self addSubview:_art];

        _title = [[UILabel alloc] initWithFrame:CGRectMake(14, 66, w - 28, 20)];
        _title.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
        _title.textColor = UIColor.whiteColor;
        _title.text = @"Not Playing";
        [self addSubview:_title];

        _artist = [[UILabel alloc] initWithFrame:CGRectMake(14, 86, w - 28, 18)];
        _artist.font = [UIFont systemFontOfSize:13];
        _artist.textColor = [UIColor colorWithWhite:1 alpha:0.6];
        [self addSubview:_artist];

        NSArray *syms = @[@"backward.fill", @"play.fill", @"forward.fill"];
        CGFloat bw = w / 3;
        for (int i = 0; i < 3; i++) {
            UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
            b.frame = CGRectMake(i * bw, h - 52, bw, 44);
            b.tag = i;
            b.tintColor = UIColor.whiteColor;
            UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:22 weight:UIImageSymbolWeightBold];
            [b setImage:[UIImage systemImageNamed:syms[i] withConfiguration:cfg] forState:UIControlStateNormal];
            [b addTarget:self action:@selector(command:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:b];
            if (i == 1) _play = b;
        }
    }
    return self;
}

- (void)command:(UIButton *)b {
    [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight] impactOccurred];
    int cmds[3] = { GCMRPreviousTrack, GCMRTogglePlayPause, GCMRNextTrack };
    if (MRSend) MRSend(cmds[b.tag], nil);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refresh];
    });
}

- (void)refresh {
    if (MRGetInfo) {
        MRGetInfo(dispatch_get_main_queue(), ^(CFDictionaryRef info) {
            NSDictionary *d = (__bridge NSDictionary *)info;
            NSString *t = d[@"kMRMediaRemoteNowPlayingInfoTitle"];
            NSString *a = d[@"kMRMediaRemoteNowPlayingInfoArtist"];
            NSData *art = d[@"kMRMediaRemoteNowPlayingInfoArtworkData"];
            self->_title.text = t.length ? t : @"Not Playing";
            self->_artist.text = a ?: @"";
            UIImage *img = art ? [UIImage imageWithData:art] : nil;
            self->_art.image = img ?: [UIImage systemImageNamed:@"music.note"];
            self->_art.contentMode = img ? UIViewContentModeScaleAspectFill : UIViewContentModeCenter;
        });
    }
    if (MRGetPlaying) {
        MRGetPlaying(dispatch_get_main_queue(), ^(Boolean playing) {
            UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:22 weight:UIImageSymbolWeightBold];
            [self->_play setImage:[UIImage systemImageNamed:playing ? @"pause.fill" : @"play.fill" withConfiguration:cfg]
                         forState:UIControlStateNormal];
        });
    }
}

@end
