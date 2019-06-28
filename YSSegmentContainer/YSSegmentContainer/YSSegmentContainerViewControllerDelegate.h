//
//  YSSegmentContainerViewControllerDelegate.h
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/27.
//  Copyright © 2019年 all. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YSSegmentContainerViewController;
@class YSIntercativeControl;

/**
 Provide viewcontrollers transition necessary element: animator and interactive.
 */
@protocol YSSegmentContainerViewControllerDelegate <NSObject>

@optional
- (id<UIViewControllerAnimatedTransitioning>)containerViewControllerTransitionInContainerViewController:(YSSegmentContainerViewController *)containerVC fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC;

- (UIPercentDrivenInteractiveTransition *)containerViewControllerTransitionInContainerViewController:(YSSegmentContainerViewController *)containerVC animator:(id<UIViewControllerAnimatedTransitioning>)animator;

@end


/**
 Default implement YSSegmentContainerViewControllerDelegate.
 */
@interface YSSegmentContainerViewControllerDefaultDelegate : NSObject<YSSegmentContainerViewControllerDelegate>

@property (nonatomic, strong) YSIntercativeControl *intercative;

@end
