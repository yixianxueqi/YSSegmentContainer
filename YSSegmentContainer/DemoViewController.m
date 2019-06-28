//
//  DemoViewController.m
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/27.
//  Copyright © 2019年 all. All rights reserved.
//

#import "DemoViewController.h"
#import "YSSegmentContainerViewController.h"
#import "YSMenuItemWrapperView.h"
#import "YSMenuItemSliderView.h"
#import "YSSegmentContainerViewControllerDelegate.h"
#import "ListViewController.h"
#import "TempViewController.h"

@interface DemoViewController ()<YSSegmentContainerViewControllerIncidentDelegate>

@property (nonatomic, strong) YSSegmentContainerViewController *segmentContainerVC;
@property (nonatomic, strong) YSSegmentContainerViewControllerDefaultDelegate *delegate;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Demo";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self customNav];
//    [self customViewWrapper];
    [self customViewSlider];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (@available(iOS 11.0, *)) {
        self.segmentContainerVC.view.frame = CGRectMake(0.0, self.view.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom);
    } else {
        self.segmentContainerVC.view.frame = CGRectMake(0.0, self.view.layoutMargins.top, self.view.bounds.size.width, self.view.bounds.size.height - self.view.layoutMargins.top - self.view.layoutMargins.bottom);
    }
}

- (void)pushTempViewController {
    
    TempViewController *tempVC = [[TempViewController alloc] init];
    [self.navigationController pushViewController:tempVC animated:true];
}

- (void)customNav {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Push" style:UIBarButtonItemStyleDone target:self action:@selector(pushTempViewController)];
}

- (void)customViewWrapper {
    
    self.segmentContainerVC = [[YSSegmentContainerViewController alloc] init];
    
     /*
      First, deploy menuView,delegate,containerVC...
      */
    self.delegate = [[YSSegmentContainerViewControllerDefaultDelegate alloc] init];
    self.segmentContainerVC.delegate = self.delegate;
    
    YSMenuItemWrapperView *menuView = [[YSMenuItemWrapperView alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, 44.0)];
//    menuView.separateLineHeight = 2.0;
//    menuView.separateLineColor = [UIColor redColor];
//    menuView.selectBGColor = [UIColor blueColor];
//    menuView.itemWrapperHeightSpace = 8.0;
    menuView.itemWrapperWidthSpace = 30.0;
    self.segmentContainerVC.menuView = menuView;
    
    NSArray *titleList = @[@"推荐", @"热门", @"体育", @"财经", @"社会", @"科技", @"幽默", @"军事", @"服装", @"教育"];
    
    // less than screen width scene
//    NSArray *titleList = @[@"推荐", @"热门", @"体育"];
//    menuView.selectBGFitItemWidth = false;
//    menuView.itemWrapperWidthSpace = 40.0;
//    menuView.isEqualItem = true;
    
    NSMutableArray *vcList = [NSMutableArray array];
    for (int i = 0; i < titleList.count; i++) {
        NSString *title = titleList[i];
        ListViewController *tempVC = [[ListViewController alloc] init];
        tempVC.title = title;
        [vcList addObject:tempVC];
    }
    self.segmentContainerVC.incidentDelegate = self;
//    self.segmentContainerVC.isAllowPanInteractive = false;
//    self.segmentContainerVC.interativePanPercent = 0.4;
    
    /*
     Then, set manage subviewcontroller
     */
    self.segmentContainerVC.viewControllers = [vcList copy];
    
    /*
     Then, add to show
     */
    [self addChildViewController:self.segmentContainerVC];
    [self.segmentContainerVC didMoveToParentViewController:self];
    [self.view addSubview:self.segmentContainerVC.view];
    
    /*
     finally, set show index; if not set, default 0.
     */
    [self.segmentContainerVC setShowIndex:1];
}

- (void)customViewSlider {
    
    self.segmentContainerVC = [[YSSegmentContainerViewController alloc] init];
    
    /*
     First, deploy menuView,delegate,containerVC...
     */
    self.delegate = [[YSSegmentContainerViewControllerDefaultDelegate alloc] init];
    self.segmentContainerVC.delegate = self.delegate;
    
    YSMenuItemSliderView *menuView = [[YSMenuItemSliderView alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, 44.0)];
    //    menuView.separateLineHeight = 2.0;
    //    menuView.separateLineColor = [UIColor redColor];
    //    menuView.itemWrapperHeightSpace = 8.0;
    menuView.itemWrapperWidthSpace = 30.0;
    self.segmentContainerVC.menuView = menuView;
    
//    NSArray *titleList = @[@"推荐", @"热门", @"体育", @"财经", @"社会", @"科技", @"幽默", @"军事", @"服装", @"教育"];
    
    // less than screen width scene
        NSArray *titleList = @[@"推荐", @"热门", @"体育"];
        menuView.sliderFitItemWidth = true;
        menuView.itemWrapperWidthSpace = 40.0;
        menuView.isEqualItem = true;
    
    NSMutableArray *vcList = [NSMutableArray array];
    for (int i = 0; i < titleList.count; i++) {
        NSString *title = titleList[i];
        ListViewController *tempVC = [[ListViewController alloc] init];
        tempVC.title = title;
        [vcList addObject:tempVC];
    }
    self.segmentContainerVC.incidentDelegate = self;
    //    self.segmentContainerVC.isAllowPanInteractive = false;
    //    self.segmentContainerVC.interativePanPercent = 0.4;
    
    /*
     Then, set manage subviewcontroller
     */
    self.segmentContainerVC.viewControllers = [vcList copy];
    
    /*
     Then, add to show
     */
    [self addChildViewController:self.segmentContainerVC];
    [self.segmentContainerVC didMoveToParentViewController:self];
    [self.view addSubview:self.segmentContainerVC.view];
    
    /*
     finally, set show index; if not set, default 0.
     */
    [self.segmentContainerVC setShowIndex:1];
}

#pragma mark - YSSegmentContainerViewControllerIncidentDelegate

- (void)segmentContainerViewController:(YSSegmentContainerViewController *)segmentViewController willChangeIndexFrom:(NSInteger)fromeIndex toIndex:(NSInteger)toIndex {
    
    NSLog(@"will changedIndex from: %ld toIndex: %ld", fromeIndex, toIndex);
}

- (void)segmentContainerViewController:(YSSegmentContainerViewController *)segmentViewController didChangeIndexFrom:(NSInteger)fromeIndex toIndex:(NSInteger)toIndex isCanceled:(BOOL)isCancel {
    
    NSLog(@"did changedIndex from: %ld toIndex: %ld isCancel: %d", fromeIndex, toIndex, isCancel);
}


@end
