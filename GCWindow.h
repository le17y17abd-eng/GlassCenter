#import <UIKit/UIKit.h>

@interface GCWindow : UIWindow <UIGestureRecognizerDelegate>
- (instancetype)initForSpringBoard;
- (void)expand;
- (void)collapse;
@end
