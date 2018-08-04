//
//  TransitionAnimationObject.m
//  TransitionAnimationDemo
//
//  Created by 余意 on 2018/8/3.
//  Copyright © 2018年 余意. All rights reserved.
//

#import "TransitionAnimationObject.h"

@implementation TransitionAnimationObject

- (instancetype)initWithTransitionAnimationObjectType:(TransitionAnimationObjectType)type
{
    self = [super init];
    if (self)
    {
        _type = type;
    }
    return self;
}

+ (instancetype)initWithTransitionAnimationObjectType:(TransitionAnimationObjectType)type
{
    return [[self alloc] initWithTransitionAnimationObjectType:type];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    switch (_type) {
        case TransitionAnimationObjectType_Push:
            [self pushAnimateTransition:transitionContext];
            break;
            
        case TransitionAnimationObjectType_Pop:
            [self popAnimateTransition:transitionContext];
            break;
            
        case TransitionAnimationObjectType_present:
            [self presentAnimateTransition:transitionContext];
            break;
            
        case TransitionAnimationObjectType_Dismiss:
            [self dismissAnimateTransition:transitionContext];
            break;
            
        default:
            break;
    }
}


- (void)pushAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    //获取目标View(secondVC.view) 和 来源View(ViewController.view)
    UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView * fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    //这里截图做动画 隐藏来源View
    UIView * tempView = [fromView snapshotViewAfterScreenUpdates:NO];
    fromView.hidden = YES;
    
    //将需要做转场的View按照顺序添加到转场容器中
    UIView * containerView = [transitionContext containerView];
    [containerView addSubview:tempView];
    [containerView addSubview:toView];
    
    CGFloat width = containerView.frame.size.width;
    CGFloat height = containerView.frame.size.height;
    
    //设置目标View的初始位置
    toView.frame = CGRectMake(width, 0, width, height);
    
    //开始做动画
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        tempView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        toView.transform = CGAffineTransformMakeTranslation(-width, 0);
    } completion:^(BOOL finished) {
        //这里要标记转场成功 假如不标记 系统会认为还在转场中 无法交互
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
        //转场失败 也要做相应的处理
        if ([transitionContext transitionWasCancelled])
        {
            fromView.hidden = NO;
            [tempView removeFromSuperview];
        }
    }];
}

- (void)popAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    //注意这里是还原 所以toView和fromView 身份互换了 toView是ViewController.view
    UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView * fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    //获取相应的视图
    UIView * containerView = [transitionContext containerView];
    UIView * tempView = [[containerView subviews] firstObject];
    
    //在fromView 下面插入toView 不然回来的时候回黑屏
    [containerView insertSubview:toView belowSubview:fromView];
    
    //将动画直接还原即可
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        tempView.transform = CGAffineTransformIdentity;
        fromView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        //标记转场
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        
        //转场成功的处理
        if (![transitionContext transitionWasCancelled])
        {
            [tempView removeFromSuperview];
            toView.hidden = NO;
        }
    }];
}

- (void)presentAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    //获取目标View(ThirdVC.view) 和 来源View(ViewController.view)
    UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView * fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    //截图做动画
    UIView * tempView = [fromView snapshotViewAfterScreenUpdates:NO];
    tempView.frame = fromView.frame;
    fromView.hidden = YES;
    
    //按照顺序假如转场动画容器中
    UIView * containerView = [transitionContext containerView];
    [containerView addSubview:tempView];
    [containerView addSubview:toView];
    
    CGFloat width = containerView.frame.size.width;
    CGFloat height = containerView.frame.size.height;
    
    //设置toView的初始化位置 在屏幕底部
    toView.frame = CGRectMake(0, height, width, 400);
    
    //做转场动画
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration
                          delay:0
         usingSpringWithDamping:0.55
          initialSpringVelocity:1
                        options:0
                     animations:^{
        tempView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        toView.transform = CGAffineTransformMakeTranslation(0, -400);
    } completion:^(BOOL finished) {
        //转场结束后一定要标记 否则会认为还在转场 无法交互
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        if ([transitionContext transitionWasCancelled])
        {
            //转场失败
            fromView.hidden = NO;
            [tempView removeFromSuperview];
        }
    }];
    
    
}

- (void)dismissAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    //dismiss的时候 fromVC和toVC身份倒过来了
    UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView * fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    //containerView里面的顺序也倒过来了 截图在最上面
    UIView * containerView = [transitionContext containerView];
    UIView * tempView = [[containerView subviews] firstObject];
    
    //做还原动画就可以了
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration
                          delay:0
         usingSpringWithDamping:0.55
          initialSpringVelocity:1
                        options:0
                     animations:^{
                         tempView.transform = CGAffineTransformIdentity;
                         fromView.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished)
    {
        //转场结束后一定要标记 否则会认为还在转场 无法交互
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        if (![transitionContext transitionWasCancelled])
        {
            //转场成功
            toView.hidden = NO;
            [tempView removeFromSuperview];
        }
    }];
    
}























@end
