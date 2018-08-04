//
//  GestureObject.m
//  TransitionAnimationDemo
//
//  Created by 余意 on 2018/8/3.
//  Copyright © 2018年 余意. All rights reserved.
//

#import "GestureObject.h"

@interface GestureObject ()

//是否完成
@property (nonatomic,assign) BOOL shouldComplete;

//目标VC
@property (nonatomic,strong) UIViewController * targetVC;

@end

@implementation GestureObject

- (void)addGestureToViewController:(UIViewController *)viewController
{
    self.targetVC = viewController;
    
    UIPanGestureRecognizer * ges = [[UIPanGestureRecognizer alloc] init];
    [ges addTarget:self action:@selector(handleGesture:)];
    [viewController.view addGestureRecognizer:ges];
}

- (void)handleGesture:(UIPanGestureRecognizer *)ges
{
    CGPoint point = [ges translationInView:ges.view];
    
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.interacting = YES;
            [self.targetVC dismissViewControllerAnimated:YES completion:nil];
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            CGFloat fraction = point.y / ges.view.frame.size.height;
            //限制在0和1之间
            fraction = MAX(0.0, MIN(fraction, 1.0));
            self.shouldComplete = fraction > 0.5;
            [self updateInteractiveTransition:fraction];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            self.interacting = NO;
            if (!self.shouldComplete || ges.state == UIGestureRecognizerStateCancelled)
            {
                //还原动画
                [self cancelInteractiveTransition];
            }
            else
            {
                //完成动画
                [self finishInteractiveTransition];
            }
            break;
        }
            
        default:
            break;
    }
}



@end
