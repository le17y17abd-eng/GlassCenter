#import "GCGlass.h"

UIVisualEffect *GCGlassEffect(void) {
    Class glass = NSClassFromString(@"UIGlassEffect"); // iOS 26+
    if (glass) {
        id e = [[glass alloc] init];
        if ([e isKindOfClass:[UIVisualEffect class]]) return e;
    }
    return [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterialDark];
}

UIVisualEffectView *GCMakeGlass(CGRect frame, CGFloat radius) {
    UIVisualEffectView *v = [[UIVisualEffectView alloc] initWithEffect:GCGlassEffect()];
    v.frame = frame;
    v.layer.cornerRadius = radius;
    v.layer.cornerCurve = kCACornerCurveContinuous;
    v.clipsToBounds = YES;
    return v;
}

#pragma mark - GCTile

@implementation GCTile {
    UIView *_bg;
    UIView *_fill;
    UIImageView *_icon;
    UIColor *_onIconColor;
}

- (instancetype)initWithFrame:(CGRect)f symbol:(NSString *)symbol circle:(BOOL)circle
                      onColor:(UIColor *)onColor onIconColor:(UIColor *)onIconColor {
    if ((self = [super initWithFrame:f])) {
        _onIconColor = onIconColor ?: UIColor.whiteColor;
        CGFloat radius = circle ? f.size.height / 2 : 26;

        if (circle) {
            _bg = [[UIView alloc] initWithFrame:self.bounds];
            _bg.backgroundColor = [UIColor colorWithWhite:1 alpha:0.16];
            _bg.layer.cornerRadius = radius;
        } else {
            _bg = GCMakeGlass(self.bounds, radius);
        }
        _bg.userInteractionEnabled = NO;
        [self addSubview:_bg];

        _fill = [[UIView alloc] initWithFrame:self.bounds];
        _fill.backgroundColor = onColor;
        _fill.alpha = 0;
        _fill.layer.cornerRadius = radius;
        _fill.layer.cornerCurve = kCACornerCurveContinuous;
        _fill.userInteractionEnabled = NO;
        [self addSubview:_fill];

        UIImageSymbolConfiguration *cfg =
            [UIImageSymbolConfiguration configurationWithPointSize:circle ? 24 : 26 weight:UIImageSymbolWeightMedium];
        _icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:symbol withConfiguration:cfg]];
        _icon.tintColor = UIColor.whiteColor;
        _icon.contentMode = UIViewContentModeCenter;
        _icon.frame = self.bounds;
        [self addSubview:_icon];

        [self addTarget:self action:@selector(down) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
        [self addTarget:self action:@selector(up) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel | UIControlEventTouchDragExit];
        [self addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)down {
    [UIView animateWithDuration:0.18 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.transform = CGAffineTransformMakeScale(0.93, 0.93);
    } completion:nil];
}

- (void)up {
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)tapped {
    [self up];
    [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight] impactOccurred];
    if (self.onTap) self.onTap(self);
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    _on = on;
    void (^apply)(void) = ^{
        self->_fill.alpha = on ? 1 : 0;
        self->_icon.tintColor = on ? self->_onIconColor : UIColor.whiteColor;
    };
    if (animated) [UIView animateWithDuration:0.22 animations:apply]; else apply();
}

@end

#pragma mark - GCSlider

@implementation GCSlider {
    UIVisualEffectView *_glass;
    UIView *_fill;
    UIImageView *_icon;
}

- (instancetype)initWithFrame:(CGRect)f symbol:(NSString *)symbol {
    if ((self = [super initWithFrame:f])) {
        _glass = GCMakeGlass(self.bounds, 28);
        [self addSubview:_glass];

        _fill = [[UIView alloc] init];
        _fill.backgroundColor = [UIColor colorWithWhite:1 alpha:0.94];
        [_glass.contentView addSubview:_fill];

        UIImageSymbolConfiguration *cfg =
            [UIImageSymbolConfiguration configurationWithPointSize:22 weight:UIImageSymbolWeightSemibold];
        _icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:symbol withConfiguration:cfg]];
        _icon.tintColor = UIColor.systemGrayColor;
        _icon.contentMode = UIViewContentModeCenter;
        _icon.frame = CGRectMake(0, f.size.height - 54, f.size.width, 40);
        [_glass.contentView addSubview:_icon];

        [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(touch:)]];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch:)]];
    }
    return self;
}

- (void)setValue:(CGFloat)value {
    _value = MAX(0, MIN(1, value));
    CGFloat h = self.bounds.size.height * _value;
    _fill.frame = CGRectMake(0, self.bounds.size.height - h, self.bounds.size.width, h);
}

- (void)touch:(UIGestureRecognizer *)g {
    self.value = 1.0 - ([g locationInView:self].y / self.bounds.size.height);
    if (self.onChange) self.onChange(self.value);
}

@end
