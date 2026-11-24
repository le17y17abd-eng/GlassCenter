#import <UIKit/UIKit.h>

// Now Playing card (artwork, title, artist, prev / play-pause / next) using MediaRemote.
@interface GCNowPlayingView : UIView
- (instancetype)initWithFrame:(CGRect)frame;
- (void)refresh;
@end
