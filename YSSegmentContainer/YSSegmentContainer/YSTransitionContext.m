//
//  YSTransitionContext.m
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/27.
//  Copyright © 2019年 all. All rights reserved.
//

#import "YSTransitionContext.h"
#import "YSSegmentContainerViewController.h"
#import "YSIntercativeControl.h"

@interface YSTransitionContext ()

@property (nonatomic, weak) UIViewController *fromVC;
@property (nonatomic, weak) UIViewController *toVC;
@property (nonatomic, weak) YSSegmentContainerViewController *containerVC;
@property (nonatomic, weak) UIView *pContainterView;
@property (nonatomic, assign) BOOL isCancelled;
@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning> animator;
@property (nonatomic, assign) BOOL interactive;
@property (nonatomic, assign) CFTimeInterval transitionDuration;
@property (nonatomic, assign) CGFloat transitionPercent;

@end

@implementation YSTransitionContext

#pragma mark - lifeCycle
- (instancetype)initWithContainerViewController:(YSSegmentContainerViewController *)containerVC containerView:(UIView *)containerView fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    
    self = [super init];
    if (self) {
        _containerVC = containerVC;
        _pContainterView = containerView;
        _fromVC = fromVC;
        _toVC = toVC;
    }
    return self;
}

#pragma mark - override
- (UIView *)containerView {
    return self.pContainterView;
}

- (UIViewController *)viewControllerForKey:(UITransitionContextViewControllerKey)key {
    
    if ([key isEqualToString:UITransitionContextFromViewControllerKey]) {
        return self.fromVC;
    } else if ([key isEqualToString:UITransitionContextToViewControllerKey]) {
        return self.toVC;
    }
    return nil;
}


- (UIView *)viewForKey:(UITransitionContextViewKey)key {
    
    if ([key isEqualToString:UITransitionContextFromViewKey]) {
        return self.fromVC.view;
    } else if ([key isEqualToString:UITransitionContextToViewKey]) {
        return self.toVC.view;
    }
    return nil;
}

- (CGRect)initialFrameForViewController:(UIViewController *)vc {
    return CGRectZero;
}

- (CGRect)finalFrameForViewController:(UIViewController *)vc {
    return CGRectZero;
}

- (UIModalPresentationStyle)presentationStyle {
    return UIModalPresentationCustom;
}

- (void)completeTransition:(BOOL)didComplete {
    
    if (didComplete) {
        [self.toVC didMoveToParentViewController:self.containerVC];
        [self.fromVC willMoveToParentViewController:nil];
        [self.fromVC.view removeFromSuperview];
        [self.fromVC removeFromParentViewController];
    } else {
        [self.toVC didMoveToParentViewController:self.containerVC];
        [self.toVC willMoveToParentViewController:nil];
        [self.toVC.view removeFromSuperview];
        [self.toVC removeFromParentViewController];
    }
    [self transitionEnd];
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    
    if (self.animator && self.interactive) {
        self.transitionPercent = percentComplete;
        self.containerView.layer.timeOffset = percentComplete * self.transitionDuration;
        [self.containerVC updateMenuItemAppearanceByPercent:percentComplete];
    }
}

- (void)finishInteractiveTransition {
    
    self.interactive = false;
    NSTimeInterval pausedTime = self.containerView.layer.timeOffset;
    self.containerView.layer.speed = 1.0;
    self.containerView.layer.timeOffset = 0.0;
    self.containerView.layer.beginTime = 0.0;
    NSTimeInterval timeSincePause = [self.containerView.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.containerView.layer.beginTime = timeSincePause;
    
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(finishChangeButtonAppear:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    NSTimeInterval remainingTime = (1 - self.transitionPercent) * self.transitionDuration;
    [self performSelector:@selector(fixBeginTimeBug) withObject:nil afterDelay:remainingTime];
}

- (void)cancelInteractiveTransition {
    
    self.interactive = false;
    self.isCancelled = true;
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(reverseCurrentAnimation:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [[NSNotificationCenter defaultCenter] postNotificationName:YSInteractionEndNotification object:self];
}

- (BOOL)transitionWasCancelled {
    return self.isCancelled;
}

- (CGAffineTransform)targetTransform {
    return CGAffineTransformIdentity;
}

- (void)pauseInteractiveTransition {
    
}

- (BOOL)isAnimated {
    if (self.animator) {
        return true;
    }
    return false;
}

#pragma mark - public
- (void)startInteractiveTransitionWithDelegate:(id<YSSegmentContainerViewControllerDelegate>)delegate {
    
    self.animator = [delegate containerViewControllerTransitionInContainerViewController:self.containerVC fromViewController:self.fromVC toViewController:self.toVC];
    self.transitionDuration = [self.animator transitionDuration:self];
    if (self.containerVC.interactive) {
        YSIntercativeControl *intervative = (YSIntercativeControl *)[delegate containerViewControllerTransitionInContainerViewController:self.containerVC animator:self.animator];
        [intervative startInteractiveTransition:self];
    } else {
        //...
    }
}

- (void)activateInteractiveTransition {
    
    self.interactive = true;
    self.isCancelled = false;
    [self.containerVC addChildViewController:self.toVC];
    self.containerView.layer.speed = 0.0;
    [self.animator animateTransition:self];
}

- (void)startUnInteractiveTransitionWithDelegate:(id<YSSegmentContainerViewControllerDelegate>)delegate {
    
    self.animator = [delegate containerViewControllerTransitionInContainerViewController:self.containerVC fromViewController:self.fromVC toViewController:self.toVC];
    self.transitionDuration = [self.animator transitionDuration:self];
    [self activateNonInteractiveTransition];
}

- (void)transitionEnd {
    
    if (self.animator && [self.animator respondsToSelector:@selector(animationEnded:)]) {
        [self.animator animationEnded:true];
    }
    BOOL isCancel = self.isCancelled;
    if (self.isCancelled) {
        [self.containerVC reverseTransition];
        self.isCancelled = false;
    }
    NSDictionary *info = @{@"fromVC": self.fromVC, @"toVC": self.toVC, @"isCancel": @(isCancel)};
    [[NSNotificationCenter defaultCenter] postNotificationName:YSContainerTransitionEndNotification object:self userInfo:info];
}

- (void)activateNonInteractiveTransition {
    
    self.interactive = false;
    self.isCancelled = false;
    [self.containerVC addChildViewController:self.toVC];
    [self.animator animateTransition:self];
}

- (void)fixBeginTimeBug {
    
    self.containerView.layer.beginTime = 0.0;
}

- (void)reverseCurrentAnimation:(CADisplayLink *)displayLink {
    
    NSTimeInterval timeOffset = self.containerView.layer.timeOffset - displayLink.duration;
    if (timeOffset > 0) {
        self.containerView.layer.timeOffset = timeOffset;
        self.transitionPercent = timeOffset / self.transitionDuration;
        [self.containerVC updateMenuItemAppearanceByPercent:self.transitionPercent];
    } else {
        [displayLink invalidate];
        self.containerView.layer.timeOffset = 0;
        self.containerView.layer.speed = 1;
        [self.containerVC updateMenuItemAppearanceByPercent:0];
        // 防止闪屏
        UIView *snapshotView = [self.fromVC.view snapshotViewAfterScreenUpdates:false];
        [self.containerView addSubview:snapshotView];
        [self performSelector:@selector(removeFakeFromView:) withObject:snapshotView afterDelay:1/60];
    }
}

- (void)removeFakeFromView:(UIView *)view {
    [view removeFromSuperview];
}

- (void)finishChangeButtonAppear:(CADisplayLink *)displayLink {
    
    double percentFrame = 1 / (self.transitionDuration * 60);
    self.transitionPercent += percentFrame;
    if (self.transitionPercent < 1.0) {
        [self.containerVC updateMenuItemAppearanceByPercent:self.transitionPercent];
    } else {
        [self.containerVC updateMenuItemAppearanceByPercent:1.0];
        [displayLink invalidate];
    }
}
#pragma mark - incident
#pragma mark - private
#pragma mark - delegate
#pragma mark - getter/setter

@end
