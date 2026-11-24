#import "GCWindow.h"
#import "GCGlass.h"
#import "GCSystem.h"
#import "GCNowPlaying.h"

@interface GCWindow ()
@property (nonatomic, strong) UIVisualEffectView *backdrop;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) GCTile *airplane, *wifi, *bluetooth, *lowPower, *rotation, *torch;
@property (nonatomic, strong) GCSlider *brightness, *volume;
@property (nonatomic, strong) GCNowPlayingView *nowPlaying;
@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, assign) CGRect triggerFrame;
@end

@implementation GCWindow

#pragma mark - Init

- (instancetype)initForSpringBoard {
    CGRect screen = UIScreen.mainScreen.bounds;
    // Invisible strip along the top edge: swipe down here to open.
    CGRect trigger = CGRectMake(0, 0, screen.size.width, 24);
    if ((self = [super initWithFrame:trigger])) {
        _triggerFrame = trigger;
        self.windowLevel = UIWindowLevelAlert + 1000;
        self.backgroundColor = UIColor.clearColor;
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;

        UIViewController *vc = [UIViewController new];
        vc.view.backgroundColor = UIColor.clearColor;
        self.rootViewController = vc;

        [self buildUI];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(triggerPan:)];
        pan.delegate = self;
        [vc.view addGestureRecognizer:pan];

        self.hidden = NO;
    }
    return self;
}

#pragma mark - UI (iOS 18 style grid, 4 columns)

- (GCTile *)tileIn:(UIView *)parent frame:(CGRect)f symbol:(NSString *)sym circle:(BOOL)circle
             color:(UIColor *)color icon:(UIColor *)icon tap:(void (^)(GCTile *))tap {
    GCTile *t = [[GCTile alloc] initWithFrame:f symbol:sym circle:circle onColor:color onIconColor:icon];
    t.onTap = tap;
    [parent addSubview:t];
    return t;
}

- (void)buildUI {
    CGRect screen = UIScreen.mainScreen.bounds;
    UIView *root = self.rootViewController.view;

    // Blurred, dimmed background
    self.backdrop = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark]];
    self.backdrop.frame = screen;
    self.backdrop.alpha = 0;
    self.backdrop.hidden = YES;
    self.backdrop.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.backdrop addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(collapse)]];
    UISwipeGestureRecognizer *up = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(collapse)];
    up.direction = UISwipeGestureRecognizerDirectionUp;
    [self.backdrop addGestureRecognizer:up];
    [root addSubview:self.backdrop];

    // Grid math: 4 columns, gap g, square unit u
    CGFloat W = MIN(screen.size.width - 32, 360), g = 12, u = (W - 3 * g) / 4;
    CGRect (^cell)(int, int, int, int) = ^CGRect(int c, int r, int cw, int rh) {
        return CGRectMake(c * (u + g), r * (u + g), cw * u + (cw - 1) * g, rh * u + (rh - 1) * g);
    };

    self.container = [[UIView alloc] initWithFrame:CGRectMake((screen.size.width - W) / 2, 60, W, 5 * u + 4 * g)];
    self.container.alpha = 0;
    self.container.hidden = YES;
    [root addSubview:self.container];

    __weak typeof(self) weak = self;
    UIColor *orange = UIColor.systemOrangeColor, *blue = UIColor.systemBlueColor;
    UIColor *white = [UIColor colorWithWhite:1 alpha:0.95], *black = UIColor.blackColor;

    // Connectivity cluster (2x2): Airplane, Wi-Fi, Bluetooth, Low Power
    CGRect cc = cell(0, 0, 2, 2);
    UIVisualEffectView *card = GCMakeGlass(cc, 32);
    [self.container addSubview:card];
    CGFloat pad = 12, d = (cc.size.width - 3 * pad) / 2;
    CGRect (^dot)(int) = ^CGRect(int i) {
        return CGRectMake(pad + (i % 2) * (d + pad), pad + (i / 2) * (d + pad), d, d);
    };
    self.airplane = [self tileIn:card.contentView frame:dot(0) symbol:@"airplane" circle:YES color:orange icon:white tap:^(GCTile *t) {
        [GCSystem setAirplane:![GCSystem airplane]]; [weak refreshSoon];
    }];
    self.wifi = [self tileIn:card.contentView frame:dot(1) symbol:@"wifi" circle:YES color:blue icon:white tap:^(GCTile *t) {
        [GCSystem setWifi:![GCSystem wifi]]; [weak refreshSoon];
    }];
    self.bluetooth = [self tileIn:card.contentView frame:dot(2) symbol:@"wave.3.right" circle:YES color:blue icon:white tap:^(GCTile *t) {
        [GCSystem setBluetooth:![GCSystem bluetooth]]; [weak refreshSoon];
    }];
    self.lowPower = [self tileIn:card.contentView frame:dot(3) symbol:@"battery.25" circle:YES color:UIColor.systemYellowColor icon:black tap:^(GCTile *t) {
        [GCSystem setLowPower:![GCSystem lowPower]]; [weak refreshSoon];
    }];

    // Now Playing (2x2)
    self.nowPlaying = [[GCNowPlayingView alloc] initWithFrame:cell(2, 0, 2, 2)];
    [self.container addSubview:self.nowPlaying];

    // Sliders (1x2 each)
    self.brightness = [[GCSlider alloc] initWithFrame:cell(0, 2, 1, 2) symbol:@"sun.max.fill"];
    self.brightness.onChange = ^(CGFloat v) { UIScreen.mainScreen.brightness = v; };
    [self.container addSubview:self.brightness];

    self.volume = [[GCSlider alloc] initWithFrame:cell(1, 2, 1, 2) symbol:@"speaker.wave.2.fill"];
    self.volume.onChange = ^(CGFloat v) { [GCSystem setVolume:(float)v]; };
    [self.container addSubview:self.volume];

    // 2x2 block of small tiles
    self.rotation = [self tileIn:self.container frame:cell(2, 2, 1, 1) symbol:@"lock.rotation" circle:NO color:UIColor.systemRedColor icon:white tap:^(GCTile *t) {
        [GCSystem setRotationLocked:![GCSystem rotationLocked]]; [weak refreshSoon];
    }];
    [self tileIn:self.container frame:cell(3, 2, 1, 1) symbol:@"lock.fill" circle:NO color:blue icon:white tap:^(GCTile *t) {
        [weak collapse]; [GCSystem lockDevice];
    }];
    [self tileIn:self.container frame:cell(2, 3, 1, 1) symbol:@"gearshape.fill" circle:NO color:blue icon:white tap:^(GCTile *t) {
        [weak launch:@"com.apple.Preferences"];
    }];
    [self tileIn:self.container frame:cell(3, 3, 1, 1) symbol:@"arrow.clockwise" circle:NO color:blue icon:white tap:^(GCTile *t) {
        [GCSystem respring];
    }];

    // Bottom shortcut row
    self.torch = [self tileIn:self.container frame:cell(0, 4, 1, 1) symbol:@"flashlight.on.fill" circle:NO color:white icon:black tap:^(GCTile *t) {
        BOOL on = ![GCSystem torch]; [GCSystem setTorch:on]; [t setOn:on animated:YES];
    }];
    [self tileIn:self.container frame:cell(1, 4, 1, 1) symbol:@"timer" circle:NO color:blue icon:white tap:^(GCTile *t) {
        [weak launch:@"com.apple.mobiletimer"];
    }];
    [self tileIn:self.container frame:cell(2, 4, 1, 1) symbol:@"plus.forwardslash.minus" circle:NO color:blue icon:white tap:^(GCTile *t) {
        [weak launch:@"com.apple.calculator"];
    }];
    [self tileIn:self.container frame:cell(3, 4, 1, 1) symbol:@"camera.fill" circle:NO color:blue icon:white tap:^(GCTile *t) {
        [weak launch:@"com.apple.camera"];
    }];
}

#pragma mark - Gestures

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)g { return !self.expanded; }

- (void)triggerPan:(UIPanGestureRecognizer *)g {
    if (self.expanded) return;
    if (g.state == UIGestureRecognizerStateChanged && [g translationInView:self].y > 30) {
        g.enabled = NO; g.enabled = YES;
        [self expand];
    }
}

#pragma mark - Show / hide

- (void)expand {
    if (self.expanded) return;
    self.expanded = YES;
    self.frame = UIScreen.mainScreen.bounds;

    CGRect cf = self.container.frame;
    cf.origin.y = MAX(self.safeAreaInsets.top, 20) + 20;
    self.container.frame = cf;

    [self refreshStates];
    self.backdrop.hidden = NO;
    self.container.hidden = NO;
    self.container.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium] impactOccurred];
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.4 options:0 animations:^{
        self.backdrop.alpha = 1;
        self.container.alpha = 1;
        self.container.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)collapse {
    if (!self.expanded) return;
    [UIView animateWithDuration:0.28 animations:^{
        self.backdrop.alpha = 0;
        self.container.alpha = 0;
        self.container.transform = CGAffineTransformMakeScale(0.93, 0.93);
    } completion:^(BOOL finished) {
        self.backdrop.hidden = YES;
        self.container.hidden = YES;
        self.frame = self.triggerFrame;
        self.expanded = NO;
    }];
}

#pragma mark - State & actions

- (void)refreshStates {
    BOOL anim = self.expanded && !self.container.hidden;
    [self.airplane setOn:[GCSystem airplane] animated:anim];
    [self.wifi setOn:[GCSystem wifi] animated:anim];
    [self.bluetooth setOn:[GCSystem bluetooth] animated:anim];
    [self.lowPower setOn:[GCSystem lowPower] animated:anim];
    [self.rotation setOn:[GCSystem rotationLocked] animated:anim];
    [self.torch setOn:[GCSystem torch] animated:anim];
    self.brightness.value = UIScreen.mainScreen.brightness;
    self.volume.value = [GCSystem volume];
    [self.nowPlaying refresh];
}

// The system needs a moment to apply a change before we can read it back.
- (void)refreshSoon {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refreshStates];
    });
}

- (void)launch:(NSString *)bundleID {
    [self collapse];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [GCSystem openApp:bundleID];
    });
}

@end
