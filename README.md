
[博客：TransitionAnimation 自定义转场动画](https://ios-misaki.github.io/iOS-Misaki.github.io/2018/08/04/TransitionAnimation-%E8%87%AA%E5%AE%9A%E4%B9%89%E8%BD%AC%E5%9C%BA%E5%8A%A8%E7%94%BB/)

&ensp;&ensp;&ensp;&ensp;在` iOS 7 `之后，苹果就开放了自定义转场的相关` api `，现在都快` iOS 12 `了，一直都没有好好研究转场动画，一个是之前没有重视，觉得花里胡哨的，另外一个是所做的项目中没有这样的转场动画需求。这里说的转场动画和上一篇[CAAnimation 系统动画](https://ios-misaki.github.io/iOS-Misaki.github.io/2018/07/26/CAAnimation%20%E7%B3%BB%E5%88%97%E5%8A%A8%E7%94%BB/)中` CATransition `动画不是一个概念，上一篇指的是单个View的转场特效，这里指的是整个控制器的转场特效。其实写上篇文章的目前也是为今天打下铺垫，复杂的转场效果也是由单个动画来组成的。

![自定义转场动画类图](https://yuyiios-work.oss-cn-shanghai.aliyuncs.com/%E5%8D%9A%E5%AE%A2/TransitionAnimation%E8%BD%AC%E5%9C%BA%E5%8A%A8%E7%94%BB/%E8%87%AA%E5%AE%9A%E4%B9%89%E8%BD%AC%E5%9C%BA%E5%8A%A8%E7%94%BB%E7%B1%BB%E5%9B%BE.png)

&ensp;&ensp;&ensp;&ensp;由图中可以看出要完成自定义转场动画，必须遵从` UIViewControllerAnimatedTransitioning `协议，协议中有两个必须实现的方法一个是返回转场时间，一个是具体转场的实现。文章会结合5个最常用的动画场景来说明转场动画。

&ensp;&ensp;&ensp;&ensp;先来看看网易严选App的转场效果，可以看出当前页面想要` Push `其他的页面的时候，当前页面会下沉同时其他页面从右边平移至左边。` Present `页面的时候，当前页面也会下沉，目标视图从底部弹出。
![网易严选Push和Pop动画](https://yuyiios-work.oss-cn-shanghai.aliyuncs.com/%E5%8D%9A%E5%AE%A2/TransitionAnimation%E8%BD%AC%E5%9C%BA%E5%8A%A8%E7%94%BB/%E7%BD%91%E6%98%93%E4%B8%A5%E9%80%89Push%E5%92%8CPop%E5%8A%A8%E7%94%BB.mov)

![网易严选Present和Dismiss动画](https://yuyiios-work.oss-cn-shanghai.aliyuncs.com/%E5%8D%9A%E5%AE%A2/TransitionAnimation%E8%BD%AC%E5%9C%BA%E5%8A%A8%E7%94%BB/%E7%BD%91%E6%98%93%E4%B8%A5%E9%80%89Present%E5%92%8CDismiss%E5%8A%A8%E7%94%BB.mov)

&ensp;&ensp;&ensp;&ensp;来看代码，在` ViewController `里面有两个按钮，分别是` Push `出` SecondVC `和` Present `出` ThirdVC `。
```
- (IBAction)pushBtnClick:(id)sender
{
    SecondViewController * vc = [[SecondViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)presentBtnClick:(id)sender
{
    ThirdViewController * vc = [[ThirdViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

```
## Push和Pop动画
### UIViewControllerAnimatedTransitioning协议
&ensp;&ensp;&ensp;&ensp;这里新建一个` AnimatedTransitioningObject `类，然后要遵循` UIViewControllerAnimatedTransitioning `协议。这个为了方便，把` Push、Pop、Present、Dismiss `这四个效果写在一起，用枚举来区分，当然也可以把每种动画效果单独用一个` AnimatedTransitioningObject `类来实现。
```
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,TransitionAnimationObjectType) {
    TransitionAnimationObjectType_Push,
    TransitionAnimationObjectType_Pop,
    TransitionAnimationObjectType_present,
    TransitionAnimationObjectType_Dismiss
};

@interface TransitionAnimationObject : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic,assign) TransitionAnimationObjectType type;

- (instancetype)initWithTransitionAnimationObjectType:(TransitionAnimationObjectType)type;

+ (instancetype)initWithTransitionAnimationObjectType:(TransitionAnimationObjectType)type;

@end
```

&ensp;&ensp;&ensp;&ensp;来看看两个必须实现的方法，在返回转场时间里也可以根据` type `来返回不同的动画时间，这里统一返回0.5秒。` pushAnimateTransition `里面实现` Push `效果转场。
```
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
```

### Push实现
```
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
```
### Pop实现
&ensp;&ensp;&ensp;&ensp; ` Push `和` Pop `是相对的关系，所以在` Pop `动画中，目标视图和来源视图互换身份，实现也是用` CGAffineTransformIdentity `来还原` Push `动画即可。
```
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

```

### UINavigationControllerDelegate代理方法
&ensp;&ensp;&ensp;&ensp;完成` AnimatedTransitioningObject `类后，再返回` ViewController `中，` ViewController `要遵循` UINavigationBarDelegate `和` UIViewControllerTransitioningDelegate `，把` SecondVC `的` transitioningDelegate `设置为自己。然后根据不同的` operation `，来返回不同的动画实现。
```
@interface ViewController () <UINavigationControllerDelegate,UIViewControllerTransitioningDelegate>

- (IBAction)pushBtnClick:(id)sender
{
    SecondViewController * vc = [[SecondViewController alloc] init];
    vc.transitioningDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
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
```
&ensp;&ensp;&ensp;&ensp;看看实现效果
![Push和Pop效果.gif](https://yuyiios-work.oss-cn-shanghai.aliyuncs.com/%E5%8D%9A%E5%AE%A2/TransitionAnimation%E8%BD%AC%E5%9C%BA%E5%8A%A8%E7%94%BB/Push%E5%92%8CPop%E6%95%88%E6%9E%9C.gif)
## Present动画和Dismiss动画

### Present实现 
```
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
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.55 initialSpringVelocity:1 options:0 animations:^{
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
```

### Dismiss实现 
```
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

    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.55 initialSpringVelocity:1 options:0 animations:^{
        tempView.transform = CGAffineTransformIdentity;
        fromView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
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
```

### UIViewControllerTransitioningDelegate代理方法
&ensp;&ensp;&ensp;&ensp;回到` ViewController `，把` ThirdVC `的` transitioningDelegate `设置为自己,然后在代理方法中自定类型。
```
- (IBAction)presentBtnClick:(id)sender
{
    ThirdViewController * vc = [[ThirdViewController alloc] init];
    vc.transitioningDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
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
```

## 手势动画
### UIPercentDrivenInteractiveTransition创建手势类
&ensp;&ensp;&ensp;&ensp;新建一个手势类` GestureObject `继承自` UIPercentDrivenInteractiveTransition `，` addGestureToViewController `是给目标控制器添加手势。
```
#import <UIKit/UIKit.h>

@interface GestureObject : UIPercentDrivenInteractiveTransition

//判断是交互的手势
@property (nonatomic,assign) BOOL interacting;

- (void)addGestureToViewController:(UIViewController *)viewController;

@end
```
&ensp;&ensp;&ensp;&ensp;然后再手势的状态之间来判断是否执行动画，这里是判断手势偏移量超过屏幕一半的高度就生效，执行相关动画，否则还原动画。
```
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
```

### UIViewControllerTransitioningDelegate代理方法
&ensp;&ensp;&ensp;&ensp;回到` ViewController `中，在` Present `出` ThirdVC `的时候添加手势，在代理方法` interactionControllerForDismissal `中指定手势。
```
- (IBAction)presentBtnClick:(id)sender
{
    ThirdViewController * vc = [[ThirdViewController alloc] init];
    vc.transitioningDelegate = self;
    [self.gestureObject addGestureToViewController:vc];
    [self presentViewController:vc animated:YES completion:nil];
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return self.gestureObject.interacting ? self.gestureObject : nil;
}
```
看看效果
![Present和Dismiss效果.gif](https://yuyiios-work.oss-cn-shanghai.aliyuncs.com/%E5%8D%9A%E5%AE%A2/TransitionAnimation%E8%BD%AC%E5%9C%BA%E5%8A%A8%E7%94%BB/Present%E5%92%8CDismiss%E6%95%88%E6%9E%9C.gif)

## 小结
&ensp;&ensp;&ensp;&ensp; ` Push `、` Pop `、` Present `、` Dismiss `、手势动画都讲解完了，可以看出，自定义转场大致的步骤是
* **根据` viewForKey `来获取转场上下文**
* **将要转场的视图加入转场容器中**
* **做出转场动画**
* **标记转场成功的状态，根据状态做相应的处理**

&ensp;&ensp;&ensp;&ensp;理解了这些，再复杂的转场动画都能一步步分解出来，下面是格瓦拉App的转场效果，第一次看的时候，觉得很酷炫，现在了解了转场的核心后，觉得不那么难了，有时间再把它的效果写出来吧。
![格瓦拉转场动画.mov](https://yuyiios-work.oss-cn-shanghai.aliyuncs.com/%E5%8D%9A%E5%AE%A2/TransitionAnimation%E8%BD%AC%E5%9C%BA%E5%8A%A8%E7%94%BB/%E6%A0%BC%E7%93%A6%E6%8B%89%E8%BD%AC%E5%9C%BA%E5%8A%A8%E7%94%BB.mov)


[**源码：TransitionAnimation**](https://github.com/iOS-Misaki/TransitionAnimation)

