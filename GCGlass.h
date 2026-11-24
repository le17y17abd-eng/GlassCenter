#import <UIKit/UIKit.h>

// Liquid Glass on iOS 26+ (UIGlassEffect), dark blur material on older versions.
UIVisualEffect *GCGlassEffect(void);
UIVisualEffectView *GCMakeGlass(CGRect frame, CGFloat radius);

// Glass tile / round button with an on-state fill.
@interface GCTile : UIControl
@property (nonatomic, readonly) BOOL on;
@property (nonatomic, copy) void (^onTap)(GCTile *tile);
- (instancetype)initWithFrame:(CGRect)frame
                       symbol:(NSString *)symbol
                       circle:(BOOL)circle
                      onColor:(UIColor *)onColor
                  onIconColor:(UIColor *)onIconColor;
- (void)setOn:(BOOL)on animated:(BOOL)animated;
@end

// Vertical glass slider (value 0...1), like iOS brightness / volume.
@interface GCSlider : UIView
@property (nonatomic) CGFloat value;
@property (nonatomic, copy) void (^onChange)(CGFloat value);
- (instancetype)initWithFrame:(CGRect)frame symbol:(NSString *)symbol;
@end
