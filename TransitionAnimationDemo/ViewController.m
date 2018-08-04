//
//  ViewController.m
//  TransitionAnimationDemo
//
//  Created by 余意 on 2018/8/3.
//  Copyright © 2018年 余意. All rights reserved.
//

#import "ViewController.h"

#import "SecondViewController.h"
#import "ThirdViewController.h"

#import "TransitionAnimationObject.h"
#import "GestureObject.h"

@interface ViewController () <UINavigationControllerDelegate,UIViewControllerTransitioningDelegate>

@property (nonatomic,strong) GestureObject * gestureObject;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.delegate = self;
    
    self.gestureObject = [[GestureObject alloc] init];
}


#pragma mark - Push && Pop
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPush)
    {
        return [TransitionAnimationObject initWithTransitionAnimationObjectType:TransitionAnimationObjectType_Push];
    }
    else if (operation == UINavigationControllerOperationPop)
    {
        return [TransitionAnimationObject initWithTransitionAnimationObjectType:TransitionAnimationObjectType_Pop];
    }
    return nil;
}

#pragma mark - Present && Dismiss
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [TransitionAnimationObject initWithTransitionAnimationObjectType:TransitionAnimationObjectType_present];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [TransitionAnimationObject initWithTransitionAnimationObjectType:TransitionAnimationObjectType_Dismiss];
}

#pragma mark - 手势
- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return self.gestureObject.interacting ? self.gestureObject : nil;
}

- (IBAction)pushBtnClick:(id)sender
{
    SecondViewController * vc = [[SecondViewController alloc] init];
    vc.transitioningDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)presentBtnClick:(id)sender
{
    ThirdViewController * vc = [[ThirdViewController alloc] init];
    vc.transitioningDelegate = self;
    [self.gestureObject addGestureToViewController:vc];
    [self presentViewController:vc animated:YES completion:nil];
}


@end
