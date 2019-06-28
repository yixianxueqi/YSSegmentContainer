//
//  YSTransitionContext.h
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/27.
//  Copyright © 2019年 all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSSegmentContainerViewControllerDelegate.h"
@class YSSegmentContainerViewController;

#define YSContainerTransitionEndNotification @"YSContainerTransitionEndNotification"
#define YSInteractionEndNotification @"YSInteractionEndNotification"

/**
 The transition context, control the transition process.
 */
@interface YSTransitionContext : NSObject<UIViewControllerContextTransitioning>

- (instancetype)initWithContainerViewController:(YSSegmentContainerViewController *)containerVC containerView:(UIView *)containerView fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC;

- (void)startInteractiveTransitionWithDelegate:(id<YSSegmentContainerViewControllerDelegate>)delegate;
- (void)activateInteractiveTransition;

- (void)startUnInteractiveTransitionWithDelegate:(id<YSSegmentContainerViewControllerDelegate>)delegate;

@end

