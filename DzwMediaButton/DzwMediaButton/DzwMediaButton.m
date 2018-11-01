//
//  DzwMediaButton.h
//  Example
//
//  Created by dzw on 2017/9/4.
//  Copyright © 2017年 段志巍. All rights reserved.
//
#import "DzwMediaButton.h"
#import <QuartzCore/QuartzCore.h>

//其它动画时长
static CGFloat animationDuration = 0.5f;
//位移动画时长
static CGFloat positionDuration = 0.3f;

CGFloat const tapCircleDiameterFull = -1.f;
CGFloat const tapCircleDiameterDefault = -2.f;

//线条颜色
//#define  [UIColor colorWithRed:248.0/255.0 green:164.0/255.0 blue:64.0/255.0 alpha:255.0/255.0]
//三角动画名称
#define TriangleAnimation @"TriangleAnimation"
//右侧直线动画名称
#define RightLineAnimation @"RightLineAnimation"

@interface DzwMediaButton ()

//是否正在执行动画
@property (nonatomic, assign) BOOL isAnimating;
//竖线
@property (nonatomic, strong) CAShapeLayer *leftLineLayer;
@property (nonatomic, strong) CAShapeLayer *rightLineLayer;
//三角
@property (nonatomic, strong) CAShapeLayer *triangleLayer;
//圆弧
@property (nonatomic, strong) CAShapeLayer *circleLayer;

@property (nonatomic,assign) CGFloat cornerRadius;
@property (nonatomic,assign) CGRect downRect;
@property (nonatomic,assign) CGRect upRect;
@property (nonatomic,assign) CGRect fadeAndClippingMaskRect;
@property (nonatomic,assign) CGPoint tapPoint;
@property (nonatomic,assign) BOOL letGo;
@property (nonatomic,strong) CALayer *backgroundColorFadeLayer;
@property (nonatomic,strong) NSMutableArray *rippleAnimationQueue;

//用于给旧的layer销毁前储存用
@property (nonatomic,strong) NSMutableArray *tempCircleLayers;
@property (nonatomic,strong) UIColor *dumbTapCircleFillColor;
@property (nonatomic,strong) UIColor *clearBackgroundDumbTapCircleColor;
@property (nonatomic,strong) UIColor *clearBackgroundDumbFadeColor;

@property(nonatomic,strong) UIColor *shadowColor;//点击阴影颜色
@property(nonatomic,assign) CGFloat loweredShadowOpacity;//默认0.5
@property(nonatomic,assign) CGFloat loweredShadowRadius;//默认1.5
@property(nonatomic,assign) CGSize loweredShadowOffset;//默认（0，1）
@property (nonatomic,assign) CGFloat liftedShadowOpacity;//默认0.5
@property (nonatomic,assign) CGFloat liftedShadowRadius;//默认4.5
@property (nonatomic,assign) CGSize liftedShadowOffset;
@property (nonatomic,strong) UIColor *touchDownColor;

@end

@implementation DzwMediaButton




//点击修改按钮状态
-(void)setSelected:(BOOL)selected{
    
    if (self.buttonState == PlayButtonStatePause) {
        self.buttonState = PlayButtonStatePlay;
    }else {
        self.buttonState = PlayButtonStatePause;
    }
    NSLog(@"%ld",(long)self.buttonState);
}


- (instancetype)initWithFrame:(CGRect)frame{
    
    if ([super initWithFrame:frame]) {
        [self setupRaised:YES];

    }
    return self;
}


-(instancetype)init{
    if (self = [super init]) {
        [self setupRaised:YES];
    }
    return self;
}


- (void)sizeToFit{
    [super sizeToFit];
    // 清除掉阴影
    self.layer.shadowOpacity = 0.f;
    self.backgroundColorFadeLayer.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y , self.bounds.size.width, self.bounds.size.height);
    self.backgroundColorFadeLayer.cornerRadius = self.cornerRadius;
    self.fadeAndClippingMaskRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y , self.bounds.size.width, self.bounds.size.height);
    [self setEnabled:self.enabled];
    [self setNeedsDisplay];
    [self.layer setNeedsDisplay];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.layer.shadowOpacity = 0.f;
    
    self.backgroundColorFadeLayer.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y , self.bounds.size.width, self.bounds.size.height);
    self.backgroundColorFadeLayer.cornerRadius = self.cornerRadius;
    
    self.fadeAndClippingMaskRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y , self.bounds.size.width, self.bounds.size.height);
    [self setEnabled:self.enabled];
    [self setNeedsDisplay];
    [self.layer setNeedsDisplay];
}

#pragma mark - Gesture Recognizer Delegate 
// 不添加点击手势，只获取到点击的位置
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint location = [touch locationInView:self];
    self.tapPoint = location;
    return NO;
}

#pragma mark - 触摸事件
- (void)paperTouchDown:(id)sender{
    self.letGo = NO;
    [self touchDownAnimations]; // Go Steelers!
}

- (void)paperTouchUp:(id)sender{
    self.letGo = YES;
    [self touchUpAnimations];
}

#pragma mark - Animation
//按钮线条动画起点处理一下
-(void)animationDidStart:(CAAnimation *)anim {
    NSString *name = [anim valueForKey:@"animationName"];
    bool isTriangle = [name isEqualToString:TriangleAnimation];
    bool isRightLine = [name isEqualToString:RightLineAnimation];
    if (isTriangle) {
        _triangleLayer.lineCap = kCALineCapRound;
    }else if (isRightLine){
        _rightLineLayer.lineCap = kCALineCapRound;
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation2 finished:(BOOL)flag{
    if ([[theAnimation2 valueForKey:@"id"] isEqualToString:@"fadeCircleOut"]) {
        [[self.tempCircleLayers objectAtIndex:0] removeFromSuperlayer];
        if (self.tempCircleLayers.count > 0) {
            [self.tempCircleLayers removeObjectAtIndex:0];
        }
    }
    NSString *name = [theAnimation2 valueForKey:@"animationName"];
    bool isTriangle = [name isEqualToString:TriangleAnimation];
    bool isRightLine = [name isEqualToString:RightLineAnimation];
    if (_buttonState == PlayButtonStatePause && isRightLine) {
        _rightLineLayer.lineCap = kCALineCapButt;
    } else if (isTriangle) {
        _triangleLayer.lineCap = kCALineCapButt;
    }
}

- (void)touchDownAnimations{
    [self fadeInBackgroundAndRippleAnimation];
}

- (void)touchUpAnimations{
    [self fadeOutBackgroundAnimation];
    [self fadeOutRipple];
}


#pragma mark - 涟漪动画

- (void)fadeInBackgroundAndRippleAnimation{
    // 在视图中产生一个带涟漪的圆圈:
    if ([DzwMediaButton isColorClear:self.backgroundColor]) {
        if (!self.fadeInColor) {
            self.fadeInColor = [self.titleLabel.textColor colorWithAlphaComponent:CGColorGetAlpha(self.clearBackgroundDumbTapCircleColor.CGColor)];
        }
        
        if (!self.touchDownColor) {
            self.touchDownColor = [self.titleLabel.textColor colorWithAlphaComponent:CGColorGetAlpha(self.clearBackgroundDumbFadeColor.CGColor)];
        }
        // 配置涟漪状态以及layer消失的时候状态
        self.backgroundColorFadeLayer.backgroundColor = self.touchDownColor.CGColor;
        CGFloat startingOpacity = self.backgroundColorFadeLayer.opacity;
        if ([[self.backgroundColorFadeLayer animationKeys] count] > 0) {
            startingOpacity = [[self.backgroundColorFadeLayer presentationLayer] opacity];
        }
        CABasicAnimation *fadeBackgroundDarker = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeBackgroundDarker.duration = self.fadeInAnimationDuration;
        fadeBackgroundDarker.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        fadeBackgroundDarker.fromValue = [NSNumber numberWithFloat:startingOpacity];
        fadeBackgroundDarker.toValue = [NSNumber numberWithFloat:1];
        fadeBackgroundDarker.fillMode = kCAFillModeForwards;
        fadeBackgroundDarker.removedOnCompletion = !NO;
        self.backgroundColorFadeLayer.opacity = 1;
        
        [self.backgroundColorFadeLayer addAnimation:fadeBackgroundDarker forKey:@"animateOpacity"];
    }else {
        if (!self.fadeInColor) {
            self.fadeInColor = [self.titleLabel.textColor colorWithAlphaComponent:CGColorGetAlpha(self.dumbTapCircleFillColor.CGColor)];
        }
    }
    
    // 计算末态大圆的直径
    CGFloat tapCircleFinalDiameter = [self calculateRippleFinalDiameter];
    // 创建一个UIView，我们可以对它的帧值进行修改(具体来说，使用. center的能力)
    UIView *tapCircleLayerSizerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tapCircleFinalDiameter, tapCircleFinalDiameter)];
    tapCircleLayerSizerView.center = self.rippleFromCenter ?CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)):self.tapPoint;
    // 计算开始路径
    UIView *startingRectSizerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tapCircleDiameterStartValue, self.tapCircleDiameterStartValue)];
    startingRectSizerView.center = tapCircleLayerSizerView.center;
    UIBezierPath *startingCirclePath = [UIBezierPath bezierPathWithRoundedRect:startingRectSizerView.frame cornerRadius:self.tapCircleDiameterStartValue / 2.f];
    
    // 结束路径
    UIView *endingRectSizerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tapCircleFinalDiameter, tapCircleFinalDiameter)];
    endingRectSizerView.center = tapCircleLayerSizerView.center;
    UIBezierPath *endingCirclePath = [UIBezierPath bezierPathWithRoundedRect:endingRectSizerView.frame cornerRadius:tapCircleFinalDiameter / 2.f];
    
    // 创建点击圆
    CAShapeLayer *tapCircle = [CAShapeLayer layer];
    tapCircle.fillColor = self.fadeInColor.CGColor;
    tapCircle.strokeColor = [UIColor clearColor].CGColor;
    tapCircle.borderColor = [UIColor clearColor].CGColor;
    tapCircle.borderWidth = 0;
    tapCircle.path = startingCirclePath.CGPath;
    
    [self.rippleAnimationQueue addObject:tapCircle];
    [self.layer insertSublayer:tapCircle above:self.backgroundColorFadeLayer];
    
    // 涟漪变大动画
    CABasicAnimation *tapCircleGrowthAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    tapCircleGrowthAnimation.duration = self.fadeInAnimationDuration;
    tapCircleGrowthAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    tapCircleGrowthAnimation.fromValue = (__bridge id)startingCirclePath.CGPath;
    tapCircleGrowthAnimation.toValue = (__bridge id)endingCirclePath.CGPath;
    tapCircleGrowthAnimation.fillMode = kCAFillModeForwards;
    tapCircleGrowthAnimation.removedOnCompletion = NO;
    
    //淡出
    CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.duration = self.fadeInAnimationDuration;
    fadeIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    fadeIn.fromValue = [NSNumber numberWithFloat:0.f];
    fadeIn.toValue = [NSNumber numberWithFloat:1.f];
    fadeIn.fillMode = kCAFillModeForwards;
    fadeIn.removedOnCompletion = NO;
    
    [tapCircle addAnimation:tapCircleGrowthAnimation forKey:@"animatePath"];
    [tapCircle addAnimation:fadeIn forKey:@"opacityAnimation"];
}

- (void)fadeOutBackgroundAnimation{
    if ([DzwMediaButton isColorClear:self.backgroundColor]) {
        CGFloat startingOpacity = self.backgroundColorFadeLayer.opacity;
        // 获取当前动画的值
        if ([[self.backgroundColorFadeLayer animationKeys] count] > 0) {
            startingOpacity = [[self.backgroundColorFadeLayer presentationLayer] opacity];
        }
        CABasicAnimation *removeFadeBackgroundDarker = [CABasicAnimation animationWithKeyPath:@"opacity"];
        removeFadeBackgroundDarker.duration = self.fadeOutAnimationDuration;
        removeFadeBackgroundDarker.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        removeFadeBackgroundDarker.fromValue = [NSNumber numberWithFloat:startingOpacity];
        removeFadeBackgroundDarker.toValue = [NSNumber numberWithFloat:0];
        removeFadeBackgroundDarker.fillMode = kCAFillModeForwards;
        removeFadeBackgroundDarker.removedOnCompletion = !NO;
        self.backgroundColorFadeLayer.opacity = 0;
        
        [self.backgroundColorFadeLayer addAnimation:removeFadeBackgroundDarker forKey:@"animateOpacity"];
    }
}

- (void)fadeOutRipple{
    //末态圆直径
    CGFloat tapCircleFinalDiameter = [self calculateRippleFinalDiameter];
    tapCircleFinalDiameter += self.tapCircleBurstAmount;
    
    UIView *endingRectSizerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tapCircleFinalDiameter, tapCircleFinalDiameter)];
    endingRectSizerView.center = self.rippleFromCenter ? CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)):self.tapPoint ;
    //末态圆的路径
    UIBezierPath *endingCirclePath = [UIBezierPath bezierPathWithRoundedRect:endingRectSizerView.frame cornerRadius:tapCircleFinalDiameter / 2.f];
    
    // 得到下一个涟漪，泛出
    CAShapeLayer *tapCircle = [self.rippleAnimationQueue firstObject];
    if (nil != tapCircle) {
        if (self.rippleAnimationQueue.count > 0) {
            [self.rippleAnimationQueue removeObjectAtIndex:0];
        }
        [self.tempCircleLayers addObject:tapCircle];
        
        
        CGPathRef startingPath = tapCircle.path;
        CGFloat startingOpacity = tapCircle.opacity;
        
        if ([[tapCircle animationKeys] count] > 0) {
            startingPath = [[tapCircle presentationLayer] path];
            startingOpacity = [[tapCircle presentationLayer] opacity];
        }
        
        // 点击圆出现
        CABasicAnimation *tapCircleGrowthAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        tapCircleGrowthAnimation.duration = self.fadeOutAnimationDuration;
        tapCircleGrowthAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        tapCircleGrowthAnimation.fromValue = (__bridge id)startingPath;
        tapCircleGrowthAnimation.toValue = (__bridge id)endingCirclePath.CGPath;
        tapCircleGrowthAnimation.fillMode = kCAFillModeForwards;
        tapCircleGrowthAnimation.removedOnCompletion = NO;
        //淡出
        CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [fadeOut setValue:@"fadeCircleOut" forKey:@"id"];
        fadeOut.delegate = self;
        fadeOut.fromValue = [NSNumber numberWithFloat:startingOpacity];
        fadeOut.toValue = [NSNumber numberWithFloat:0.f];
        fadeOut.duration = self.fadeOutAnimationDuration;
        fadeOut.fillMode = kCAFillModeForwards;
        fadeOut.removedOnCompletion = NO;
        
        [tapCircle addAnimation:tapCircleGrowthAnimation forKey:@"animatePath"];
        [tapCircle addAnimation:fadeOut forKey:@"opacityAnimation"];
    }
}

- (CGFloat)calculateRippleFinalDiameter
{
    CGFloat finalDiameter = self.tapCircleDiameter;
    if (self.tapCircleDiameter == tapCircleDiameterFull) {
        CGFloat centerWidth   = self.frame.size.width;
        CGFloat centerHeight  = self.frame.size.height;
        CGFloat tapWidth      = 2 * MAX(self.tapPoint.x, centerWidth - self.tapPoint.x);
        CGFloat tapHeight     = 2 * MAX(self.tapPoint.y, centerHeight - self.tapPoint.y);
        CGFloat desiredWidth  = self.rippleFromCenter ? centerWidth:tapWidth;
        CGFloat desiredHeight = self.rippleFromCenter ? centerHeight:tapHeight;
        CGFloat diameter      = sqrt(pow(desiredWidth, 2) + pow(desiredHeight, 2));
        finalDiameter = diameter;
    }
    else if (self.tapCircleDiameter < tapCircleDiameterFull) {    // default
        finalDiameter = MAX(self.frame.size.width, self.frame.size.height);
    }
    return finalDiameter;
}

#pragma mark - 初始化线条动画元素
- (void)addTriangleLayer {
    CGFloat a = self.bounds.size.width;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(a*0.3,a*0.4)];
    [path addLineToPoint:CGPointMake(a*0.3,a*0.3)];
    [path addLineToPoint:CGPointMake(a*0.7,a*0.5)];
    [path addLineToPoint:CGPointMake(a*0.3,a*0.7)];
    [path addLineToPoint:CGPointMake(a*0.3,a*0.4)];
    
    _triangleLayer = [CAShapeLayer layer];
    _triangleLayer.path = path.CGPath;
    _triangleLayer.fillColor = [UIColor clearColor].CGColor;
    _triangleLayer.strokeColor = self.LineColor.CGColor;
    _triangleLayer.lineWidth = [self lineWidth];
    _triangleLayer.lineCap = kCALineCapButt;
    _triangleLayer.lineJoin = kCALineJoinRound;
    _triangleLayer.strokeEnd = 0;
    [self.layer addSublayer:_triangleLayer];
}


//左竖线
- (void)addLeftLineLayer {
    CGFloat a = self.bounds.size.width;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(a*0.3,a*0.4)];
    [path addLineToPoint:CGPointMake(a*0.3,a*0.6)];
    
    _leftLineLayer = [CAShapeLayer layer];
    _leftLineLayer.path = path.CGPath;
    _leftLineLayer.fillColor = [UIColor clearColor].CGColor;
    _leftLineLayer.strokeColor = self.LineColor.CGColor;
    _leftLineLayer.lineWidth = [self lineWidth];
    _leftLineLayer.lineCap = kCALineCapRound;
    _leftLineLayer.lineJoin = kCALineJoinRound;
    
    [self.layer addSublayer:_leftLineLayer];
}

// 右竖线
- (void)addRightLineLayer {
    
    CGFloat a = self.bounds.size.width;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(a*0.6,0.7*a)];
    [path addLineToPoint:CGPointMake(a*0.7,0.2*a)];
    
    _rightLineLayer = [CAShapeLayer layer];
    _rightLineLayer.path = path.CGPath;
    _rightLineLayer.fillColor = [UIColor clearColor].CGColor;
    _rightLineLayer.strokeColor = self.LineColor.CGColor;
    _rightLineLayer.lineWidth = [self lineWidth];
    _rightLineLayer.lineCap = kCALineCapRound;
    _rightLineLayer.lineJoin = kCALineJoinRound;
    [self.layer addSublayer:_rightLineLayer];
}

// 圆弧
- (void)addCircleLayer {
    
    CGFloat a = self.bounds.size.width;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(a*0.7,a*0.7)];
    [path addArcWithCenter:CGPointMake(a*0.5, a*0.6) radius:sqrt(2)*0.2*a startAngle:M_PI*0.25 endAngle:M_PI*0.75 clockwise:YES];
    self.circleLayer = [CAShapeLayer layer];
    self.circleLayer.path = path.CGPath;
    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleLayer.strokeColor = self.LineColor.CGColor;
    self.circleLayer.lineWidth = [self lineWidth];
    self.circleLayer.lineCap = kCALineCapRound;
    self.circleLayer.lineJoin = kCALineJoinRound;
    self.circleLayer.strokeEnd = 0;
    [self.layer addSublayer:self.circleLayer];
}

#pragma mark - 从暂停到播放 动画

- (void)actionPositiveAnimation {
    //开始三角动画
    [self strokeEndAnimationFrom:0 to:1 onLayer:_triangleLayer name:TriangleAnimation duration:animationDuration delegate:self];
    //开始右侧线条动画
    [self strokeEndAnimationFrom:1 to:0 onLayer:_rightLineLayer name:RightLineAnimation duration:animationDuration/4 delegate:self];
    //开始画弧动画
    [self strokeEndAnimationFrom:0 to:1 onLayer:_circleLayer name:nil duration:animationDuration/4 delegate:nil];
    //开始逆向画弧动画
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  animationDuration*0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [self circleStartAnimationFrom:0 to:1];
    });
    //开始左侧线条缩短动画
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  animationDuration*0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        //左侧竖线动画
        [self strokeEndAnimationFrom:1 to:0 onLayer:self.leftLineLayer name:nil duration:animationDuration/2 delegate:nil];
    });
}


#pragma mark - 从播放到暂停 跟上面是反向的过程
- (void)actionInverseAnimation {
    [self strokeEndAnimationFrom:1 to:0 onLayer:_triangleLayer name:TriangleAnimation duration:animationDuration delegate:self];
    [self strokeEndAnimationFrom:0 to:1 onLayer:_leftLineLayer name:nil duration:animationDuration/2 delegate:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  animationDuration*0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [self circleStartAnimationFrom:1 to:0];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  animationDuration*0.75 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [self strokeEndAnimationFrom:0 to:1 onLayer:self->_rightLineLayer name:RightLineAnimation duration:animationDuration/4 delegate:self];
        [self strokeEndAnimationFrom:1 to:0 onLayer:self->_circleLayer name:nil duration:animationDuration/4 delegate:nil];
    });
}


#pragma mark - 通用执行strokeEnd动画
- (CABasicAnimation *)strokeEndAnimationFrom:(CGFloat)fromValue to:(CGFloat)toValue onLayer:(CALayer *)layer name:(NSString*)animationName duration:(CGFloat)duration delegate:(id)delegate {
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.duration = duration;
    strokeEndAnimation.fromValue = @(fromValue);
    strokeEndAnimation.toValue = @(toValue);
    strokeEndAnimation.fillMode = kCAFillModeForwards;
    strokeEndAnimation.removedOnCompletion = NO;
    [strokeEndAnimation setValue:animationName forKey:@"animationName"];
    strokeEndAnimation.delegate = delegate;
    [layer addAnimation:strokeEndAnimation forKey:nil];
    return strokeEndAnimation;
}

// 画弧改变起始位置动画
- (void)circleStartAnimationFrom:(CGFloat)fromValue to:(CGFloat)toValue {
    CABasicAnimation *circleAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    circleAnimation.duration = animationDuration/4;
    circleAnimation.fromValue = @(fromValue);
    circleAnimation.toValue = @(toValue);
    circleAnimation.fillMode = kCAFillModeForwards;
    circleAnimation.removedOnCompletion = NO;
    [_circleLayer addAnimation:circleAnimation forKey:nil];
}

- (CGFloat)lineWidth {
    return self.bounds.size.width * 0.05;
}

#pragma mark - 竖线动画
//播放竖线动画
- (void)linePositiveAnimation {
    
    CGFloat a = self.bounds.size.width;
    //左侧缩放动画
    UIBezierPath *leftPath1 = [UIBezierPath bezierPath];
    [leftPath1 moveToPoint:CGPointMake(0.3*a,0.4*a)];
    [leftPath1 addLineToPoint:CGPointMake(0.3*a,a)];
    _leftLineLayer.path = leftPath1.CGPath;
    [_leftLineLayer addAnimation:[self pathAnimationWithDuration:positionDuration/2] forKey:nil];
    //右侧竖线位移动画
    UIBezierPath *rightPath1 = [UIBezierPath bezierPath];
    [rightPath1 moveToPoint:CGPointMake(0.7*a, 0.7*a)];
    [rightPath1 addLineToPoint:CGPointMake(0.7*a,0.2*a)];
    _rightLineLayer.path = rightPath1.CGPath;
    [_rightLineLayer addAnimation:[self pathAnimationWithDuration:positionDuration/2] forKey:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  positionDuration/2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        //左侧位移动画
        UIBezierPath *leftPath2 = [UIBezierPath bezierPath];
        [leftPath2 moveToPoint:CGPointMake(a*0.3,a*0.3)];
        [leftPath2 addLineToPoint:CGPointMake(a*0.3,a*0.8)];
        self.leftLineLayer.path = leftPath2.CGPath;
        [self.leftLineLayer addAnimation:[self pathAnimationWithDuration:positionDuration/2] forKey:nil];
        
        //右侧竖线缩放动画
        UIBezierPath *rightPath2 = [UIBezierPath bezierPath];
        [rightPath2 moveToPoint:CGPointMake(a*0.7,a*0.8)];
        [rightPath2 addLineToPoint:CGPointMake(a*0.7,a*0.2)];
        self->_rightLineLayer.path = rightPath2.CGPath;
        [self->_rightLineLayer addAnimation:[self pathAnimationWithDuration:positionDuration/2] forKey:nil];
    });
}

//竖线动画 暂停
- (void)lineInverseAnimation {
    
    CGFloat a = self.bounds.size.width;
    //左侧位移动画
    UIBezierPath *leftPath1 = [UIBezierPath bezierPath];
    [leftPath1 moveToPoint:CGPointMake(0.3*a,0.4*a)];
    [leftPath1 addLineToPoint:CGPointMake(0.3*a,0.9*a)];
    _leftLineLayer.path = leftPath1.CGPath;
    [_leftLineLayer addAnimation:[self pathAnimationWithDuration:positionDuration/2] forKey:nil];
    
    //右侧竖线位移动画
    UIBezierPath *rightPath1 = [UIBezierPath bezierPath];
    [rightPath1 moveToPoint:CGPointMake(0.7*a, 0.7*a)];
    [rightPath1 addLineToPoint:CGPointMake(0.7*a,0.2*a)];
    _rightLineLayer.path = rightPath1.CGPath;
    [_rightLineLayer addAnimation:[self pathAnimationWithDuration:positionDuration/2] forKey:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  positionDuration/2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        //左侧竖线缩放动画
        UIBezierPath *leftPath2 = [UIBezierPath bezierPath];
        [leftPath2 moveToPoint:CGPointMake(a*0.3,0.3*a)];
        [leftPath2 addLineToPoint:CGPointMake(a*0.3,0.7*a)];
        self.leftLineLayer.path = leftPath2.CGPath;
        [self.leftLineLayer addAnimation:[self pathAnimationWithDuration:positionDuration/2] forKey:nil];
        
        //右侧竖线缩放动画
        UIBezierPath *rightPath2 = [UIBezierPath bezierPath];
        [rightPath2 moveToPoint:CGPointMake(a*0.7,0.7*a)];
        [rightPath2 addLineToPoint:CGPointMake(a*0.7,0.3*a)];
        self->_rightLineLayer.path = rightPath2.CGPath;
        [self->_rightLineLayer addAnimation:[self pathAnimationWithDuration:positionDuration/2] forKey:nil];
    });
}

//path 动画方法
- (CABasicAnimation *)pathAnimationWithDuration:(CGFloat)duration {
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.duration = duration;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    return pathAnimation;
}

#pragma mark - Setter
- (void)setButtonState:(PlayButtonState)buttonState {
    //如果正在执行动画则不再执行下面操作
    if (_isAnimating == true) {return;}
    _buttonState = buttonState;
    
    if (buttonState == PlayButtonStatePause) {//播放
        _isAnimating = true;
        //竖线正向动画 再执行画弧、画三角动画
        dispatch_async(dispatch_get_main_queue(), ^{
            [self linePositiveAnimation];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  positionDuration * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [self actionPositiveAnimation];
        });
    } else if (buttonState == PlayButtonStatePlay) {//暂停
        _isAnimating = true;
        //先执行画弧、画三角动画 再执行竖线位移动画，结束动动画要比开始动画块 再竖线逆向动画
        [self actionInverseAnimation];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  animationDuration * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [self lineInverseAnimation];
        });
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  (positionDuration + animationDuration) * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        self->_isAnimating = false;
    });
}

- (void)setCornerRadius:(CGFloat)cornerRadius{
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = _cornerRadius;
    self.backgroundColorFadeLayer.cornerRadius = _cornerRadius;
    
    [self layoutSubviews];
}

- (void)setRippleFromCenter:(BOOL)rippleFromCenter{
    if (_rippleFromCenter != rippleFromCenter) {
        _rippleFromCenter = rippleFromCenter;
    }
}

- (void)setupRaised:(BOOL)isRaised{
    self.LineColor = [UIColor whiteColor];  
    self.letGo = YES;
    // 涟漪阴影 - fadein
    self.loweredShadowOpacity = 0.5f;
    self.loweredShadowRadius  = 1.5f;
    self.loweredShadowOffset  = CGSizeMake(0, 1);
    // 涟漪阴影 - fadeout
    self.liftedShadowOpacity = 0.5f;
    self.liftedShadowRadius  = 4.5f;
    self.liftedShadowOffset  = CGSizeMake(2, 4);
    //准备动画需要的参数
    self.fadeInAnimationDuration  = 0.25f;
    self.fadeOutAnimationDuration    = self.fadeInAnimationDuration * 2.5f + 0.5f;
    self.cornerRadius = 0;
    self.fadeInColor = nil;
    self.touchDownColor = nil;
    self.shadowColor = [UIColor colorWithWhite:0.2f alpha:1.f];
    self.rippleFromCenter  = NO;
    //    self.rippleBeyondBounds = NO;
    self.tapCircleDiameterStartValue = 5.f;
    self.tapCircleDiameter = tapCircleDiameterDefault;
    self.tapCircleBurstAmount = 100.f;
    self.dumbTapCircleFillColor = [UIColor colorWithWhite:0.1 alpha:0.16f];
    self.clearBackgroundDumbTapCircleColor = [UIColor colorWithWhite:0.3 alpha:0.12f];
    self.clearBackgroundDumbFadeColor = [UIColor colorWithWhite:0.3 alpha:0.12f];
    
    self.rippleAnimationQueue = [NSMutableArray array];
    self.tempCircleLayers = [NSMutableArray array];
    
    self.fadeAndClippingMaskRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y , self.bounds.size.width, self.bounds.size.height);
    self.backgroundColorFadeLayer = [[CALayer alloc] init];
    self.backgroundColorFadeLayer.frame = self.fadeAndClippingMaskRect;
    self.backgroundColorFadeLayer.cornerRadius = self.cornerRadius;
    self.backgroundColorFadeLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.backgroundColorFadeLayer.opacity = 0;
    [self.layer insertSublayer:self.backgroundColorFadeLayer atIndex:0];
    
    self.layer.masksToBounds = NO;
    self.clipsToBounds = NO;
    
    [self.layer setNeedsDisplayOnBoundsChange:YES];
    [self setContentMode:UIViewContentModeRedraw];
    
    self.fadeInColor = nil;
    self.touchDownColor = nil;
    self.layer.shadowOpacity = 0.f;
    
    [self addTarget:self action:@selector(paperTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(paperTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(paperTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    [self addTarget:self action:@selector(paperTouchUp:) forControlEvents:UIControlEventTouchCancel];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:tapGestureRecognizer];
    
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
    [self addTriangleLayer];
    [self addLeftLineLayer];
    [self addRightLineLayer];
    [self addCircleLayer];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    [self setNeedsDisplay];
}

-(void)setLineColor:(UIColor *)LineColor{
    _LineColor = LineColor;
    _triangleLayer.strokeColor = _LineColor.CGColor;
    _leftLineLayer.strokeColor = _LineColor.CGColor;
    _rightLineLayer.strokeColor = _LineColor.CGColor;
    _circleLayer.strokeColor = _LineColor.CGColor;
}


#pragma mark - Private
+ (BOOL)isColorClear:(UIColor *)color
{
    if (color == [UIColor clearColor]) { return YES; }
    
    NSUInteger totalComponents = CGColorGetNumberOfComponents(color.CGColor);
    BOOL isGreyscale = (totalComponents == 2) ? YES : NO;
    CGFloat *components = (CGFloat *)CGColorGetComponents(color.CGColor);
    if (!components) { return YES; }
    if(isGreyscale) {
        if (components[1] <= 0) { return YES; }
    } else {
        if (components[3] <= 0) { return YES; }
    }
    return NO;
}


@end
