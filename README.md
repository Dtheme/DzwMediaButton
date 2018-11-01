# DzwMediaButton
工程使用过的多媒体播放动画按钮，主动画部分模仿爱奇艺播放按钮，添加了点击涟漪效果，涟漪效果的想法来自itunes中的按钮。

### 主要思路

DzwMediaButton继承自UIButton，在UIButton基础上添加动画。按钮有2种状态：

```objective-c
typedef NS_ENUM(NSInteger,PlayButtonState) {
    PlayButtonStatePause = 0,
    PlayButtonStatePlay
};
```



动画在状态切换时发生，整个动画可以拆解成2大部分：线条动画和点击涟漪动画。

#### 线条动画：

你可以通过Simulator-Debug-Slow Animation查看动画细节 或者拆解gif图查看动画细节，这里以暂停到播放为例：

```objective-c
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
```

具体的实现细节你可以进一步看代码。



#### 涟漪动画

涟漪动画就是点击按钮以后从按钮中间，或者你点击的点泛起一个圆（可以通过下面属性设置）：

```
// 涟漪是否从按钮中心泛出 YES：按钮中心 NO：从点击处泛出
@property (nonatomic,assign) BOOL rippleFromCenter;
```

核心部分：

```objective-c
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
```



### 使用

由于DzwMediaButton封装自UIButton，使用上与UIbutton一样。以demo中的效果为例：

```objective-c
DzwMediaButton *button = [[DzwMediaButton alloc]initWithFrame:CGRectMake(self.view.center.x-100, self.view.center.y-100, 200, 200)];
button.buttonState = PlayButtonStatePause;
button.layer.cornerRadius = 100;
button.layer.masksToBounds = YES;
button.fadeInAnimationDuration = 0;
button.LineColor = [UIColor colorWithRed:253.0/255.0 green:246.0/255.0 blue:229.0/255.0 alpha:255.0/255.0];
button.backgroundColor = [UIColor blackColor];
button.fadeInColor = [UIColor colorWithRed:92.0/255.0 green:208.0/255.0 blue:194.0/255.0 alpha:255.0/255.0];
[button addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
[self.view addSubview:button];
```



注意：在使用时要在button的点击方法中改变按钮的选择状态。

```objective-c
- (void)action:(UIButton *)sender{    
    sender.selected = !sender.selected;
}
```





下面这些是动画相关的公开属性用来修改动画相关的参数：

```objective-c
// 按钮状态
@property (nonatomic, assign) PlayButtonState buttonState;

// 涟漪出现的时间
@property (nonatomic,assign) CGFloat fadeInAnimationDuration;

// 涟漪淡出的时间 默认：2 * fadeInAnimationDuration
@property (nonatomic,assign) CGFloat fadeOutAnimationDuration;

// 涟漪的起始直径 Default 5.f
@property (nonatomic,assign) CGFloat tapCircleDiameterStartValue;

// 涟漪最大直径
@property (nonatomic,assign) CGFloat tapCircleDiameter;

// 涟漪圆最后放大到多大的圆（直径）
@property (nonatomic,assign) CGFloat tapCircleBurstAmount;

// 点击处涟漪圆的颜色  默认：[UIColor colorWithWhite:0.1 alpha:0.2f]
@property (nonatomic,strong) UIColor *fadeInColor;

// 涟漪是否从按钮中心泛出 YES：按钮中心 NO：从点击处泛出
@property (nonatomic,assign) BOOL rippleFromCenter;

// 线颜色 默认：[UIColor WhiteColor];
@property (nonatomic, strong) UIColor *LineColor;

```





整体效果图：



<div align=center><img src="https://github.com/Dtheme/DzwMediaButton/blob/master/gif/button.gif"/></div>
