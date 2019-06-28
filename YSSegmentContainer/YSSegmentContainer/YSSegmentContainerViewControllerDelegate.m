//
//  YSSegmentContainerViewControllerDelegate.m
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/27.
//  Copyright © 2019年 all. All rights reserved.
//

#import "YSSegmentContainerViewControllerDelegate.h"
#import "YSSegmentContainerViewController.h"
#import "YSIntercativeControl.h"
#import "YSAnimator.h"

@implementation YSSegmentContainerViewControllerDefaultDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        self.intercative = [[YSIntercativeControl alloc] init];
    }
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)containerViewControllerTransitionInContainerViewController:(YSSegmentContainerViewController *)containerVC fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    
    NSInteger fromIndex = [containerVC.viewControllers indexOfObject:fromVC];
    NSInteger toIndex = [containerVC.viewControllers indexOfObject:toVC];
    YSTransitionDirection direction = fromIndex > toIndex ? YSTransitionDirection_Left : YSTransitionDirection_Right;
    YSAnimator *animator = [[YSAnimator alloc] initWithDirection:direction];
    return animator;
}

- (id<UIViewControllerInteractiveTransitioning>)containerViewControllerTransitionInContainerViewController:(YSSegmentContainerViewController *)containerVC animator:(id<UIViewControllerAnimatedTransitioning>)animator {
    
    return self.intercative;
}

@end
