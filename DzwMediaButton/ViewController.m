//
//  ViewController.m
//  DzwMediaButton
//
//  Created by dzw on 2018/10/31.
//  Copyright © 2018 dzw. All rights reserved.
//

#import "ViewController.h"
#import "DzwMediaButton.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
}

- (void)action:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    NSLog(@"button action");
}

@end
