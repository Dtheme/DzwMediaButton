//
//  DzwMediaButton.h
//  Example
//
//  Created by dzw on 2017/9/4.
//  Copyright © 2017年 段志巍. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,PlayButtonState) {
    PlayButtonStatePause = 0,
    PlayButtonStatePlay
};

@interface DzwMediaButton : UIButton <UIGestureRecognizerDelegate, CAAnimationDelegate>


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

@end
