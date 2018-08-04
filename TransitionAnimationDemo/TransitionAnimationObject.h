//
//  TransitionAnimationObject.h
//  TransitionAnimationDemo
//
//  Created by 余意 on 2018/8/3.
//  Copyright © 2018年 余意. All rights reserved.
//

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
