//
//  YSSegmentContainerViewController.h
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/27.
//  Copyright © 2019年 all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSSegmentContainerViewControllerDelegate.h"
@class YSMenuItemView;
@class YSSegmentContainerViewController;

/**
 The behaviour of container managed subviewcontrollers;
 @Note fromIndex maybe NSNotFound if not exist.
 */
@protocol YSSegmentContainerViewControllerIncidentDelegate <NSObject>

@optional
- (void)segmentContainerViewController:(YSSegmentContainerViewController *)segmentViewController willChangeIndexFrom:(NSInteger)fromeIndex toIndex:(NSInteger)toIndex;
- (void)segmentContainerViewController:(YSSegmentContainerViewController *)segmentViewController didChangeIndexFrom:(NSInteger)fromeIndex toIndex:(NSInteger)toIndex isCanceled:(BOOL)isCancel;

@end


/**
 The tranistion contatiner.
 
 */
@interface YSSegmentContainerViewController : UIViewController

// managed subviewcontrollers
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, readonly) NSInteger selectIndex;
// current status
@property (nonatomic, assign) BOOL interactive;
// default true
@property (nonatomic, assign) BOOL isAllowPanInteractive;
// transition is completed of cancel depend on progress
@property (nonatomic, assign) CGFloat interativePanPercent;
/*
 Provide the animator<UIViewControllerAnimatedTransitioning> and interactive<UIPercentDrivenInteractiveTransition>.
 You have to provide it!
 Default has been provide:
 Animator: YSAnimator
 Interactive: YSSegmentContainerViewControllerDefaultDelegate
 */
@property (nonatomic, weak) id<YSSegmentContainerViewControllerDelegate> delegate;

@property (nonatomic, weak) id<YSSegmentContainerViewControllerIncidentDelegate> incidentDelegate;
/*
 The top tabView.
 Default has been provide:YSMenuItemWrapperView, YSMenuItemSliderView.
 If you want to show yourself tabView, you should implement subclass of YSMenuItemView.
 */
@property (nonatomic, strong) YSMenuItemView *menuView;

// set special Index of subviewcontrollers, default 0;
- (void)setShowIndex:(NSInteger)index;

- (void)reverseTransition;
- (void)updateMenuItemAppearanceByPercent:(CGFloat)percent;

@end
