//
//  GestureObject.h
//  TransitionAnimationDemo
//
//  Created by 余意 on 2018/8/3.
//  Copyright © 2018年 余意. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GestureObject : UIPercentDrivenInteractiveTransition

//判断是交互的手势
@property (nonatomic,assign) BOOL interacting;

- (void)addGestureToViewController:(UIViewController *)viewController;

@end
