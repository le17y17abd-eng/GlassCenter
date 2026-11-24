#import <UIKit/UIKit.h>
#import "GCWindow.h"

@interface SBLockScreenManager : NSObject
@end

static GCWindow *gcWindow;

// iOS 13+ windows must be attached to a UIWindowScene to be displayed.
static void GCCreateWindow(void) {
    if (gcWindow) return;
    gcWindow = [[GCWindow alloc] initForSpringBoard];
    CGRect triggerFrame = gcWindow.frame;

    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            gcWindow.windowScene = (UIWindowScene *)scene;
            break;
        }
    }
    gcWindow.frame = triggerFrame;
    gcWindow.hidden = NO;
}

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        GCCreateWindow();
    });
}
%end

// Close the panel when the device is locked.
%hook SBLockScreenManager
- (void)lockUIFromSource:(int)source withOptions:(id)options {
    %orig;
    dispatch_async(dispatch_get_main_queue(), ^{ [gcWindow collapse]; });
}
%end
