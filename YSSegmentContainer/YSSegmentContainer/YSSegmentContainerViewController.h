//
//  YSSegmentContainerViewController.h
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/27.
//  Copyright © 2019年 all. All rights reserved.
//

#import <UIKit/UIKit.h>

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
// default true
@property (nonatomic, assign) BOOL isAllowPanInteractive;

@property (nonatomic, weak) id<YSSegmentContainerViewControllerIncidentDelegate> incidentDelegate;
// pan translate width in view, >= widthThreshold or <= -widthThreshold is finshed; other id canceled, default 0.3
@property (nonatomic, assign) CGFloat widthThreshold;
/*
 The top tabView.
 Default has been provide:YSMenuItemWrapperView, YSMenuItemSliderView.
 If you want to show yourself tabView, you should implement subclass of YSMenuItemView.
 */
@property (nonatomic, strong) YSMenuItemView *menuView;

// set special Index of subviewcontrollers, default 0;
- (void)setShowIndex:(NSInteger)index;

@end
