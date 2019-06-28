//
//  YSAnimator.m
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/27.
//  Copyright © 2019年 all. All rights reserved.
//

#import "YSAnimator.h"

@interface YSAnimator ()

@property (nonatomic, assign) YSTransitionDirection direction;

@end

@implementation YSAnimator

- (instancetype)initWithDirection:(YSTransitionDirection)direction {
    
    self = [super init];
    if (self) {
        _direction = direction;
    }
    return self;
}


- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = transitionContext.containerView;
    UIViewController *fromVC = [transitionContext viewControllerForKey: UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    CGFloat width = containerView.bounds.size.width;
    
    CGAffineTransform toViewTransform = CGAffineTransformIdentity;
    CGAffineTransform fromViewTransform = CGAffineTransformIdentity;
    
    CGFloat translate = (self.direction == YSTransitionDirection_Left ? width : -width);
    fromViewTransform = CGAffineTransformMakeTranslation(translate, 0);
    toViewTransform = CGAffineTransformMakeTranslation(-translate, 0);
    
    [containerView addSubview:toVC.view];
    toVC.view.frame = CGRectMake(0, 0, width, containerView.bounds.size.height);
    toVC.view.transform = toViewTransform;
    [UIView animateWithDuration:duration animations:^{
        fromVC.view.transform = fromViewTransform;
        toVC.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        fromVC.view.transform = CGAffineTransformIdentity;
        toVC.view.transform = CGAffineTransformIdentity;
        BOOL cancel = transitionContext.transitionWasCancelled;
        [transitionContext completeTransition:!cancel];
    }];
}

@end
