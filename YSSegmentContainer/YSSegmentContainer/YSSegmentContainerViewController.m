//
//  YSSegmentContainerViewController.m
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/27.
//  Copyright © 2019年 all. All rights reserved.
//

#import "YSSegmentContainerViewController.h"
#import "YSMenuItemView.h"

typedef NS_ENUM(NSInteger, YSDirectionType) {
    YSDirectionType_Left = -1,
    YSDirectionType_Right = 1
};

@interface YSSegmentContainerViewController ()<UIScrollViewDelegate>

@property (nonatomic, readwrite) NSInteger selectIndex;
@property (nonatomic, assign) NSInteger preSelectIndex;

@property (nonatomic, strong) NSArray *itemTitles;
@property (nonatomic, strong) UIScrollView *containerView;

@property (nonatomic, assign) BOOL needSelectAnimate;
@property (nonatomic, assign) BOOL isPanProcessing;

@end

@implementation YSSegmentContainerViewController

#pragma mark - lifeCycle
- (instancetype)init {
    self = [super init];
    if (self) {
        _selectIndex = NSNotFound;
        _preSelectIndex = NSNotFound;
        _isAllowPanInteractive = true;
        _widthThreshold = 0.3;
        _needSelectAnimate = true;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepareData];
    [self customView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initializeShow];
    self.containerView.scrollEnabled = self.isAllowPanInteractive;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.containerView.frame = CGRectMake(0.0, CGRectGetMaxY(self.menuView.frame), self.view.bounds.size.width, self.view.bounds.size.height - self.menuView.bounds.size.height);
}

#pragma mark - public
- (void)setShowIndex:(NSInteger)index {
    
    self.selectIndex = index;
    [self.menuView chooseIndex:index];
}

- (void)updateMenuItemAppearanceFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex percent:(CGFloat)percent {
    
    [self.menuView setFromIndex:fromIndex toIndex:toIndex progress:fabs(percent)];
}

#pragma mark - incident
#pragma mark - private
- (void)prepareData {
    
    NSMutableArray *titleList = [NSMutableArray array];
    for (int i = 0; i < self.viewControllers.count; i++) {
        UIViewController *vc = self.viewControllers[i];
        [titleList addObject:(vc.title.length ? vc.title : [NSString stringWithFormat:@"%d", i])];
    }
    self.itemTitles = [titleList copy];
}

- (void)customView {
    
    [self.view addSubview:self.menuView];
    self.menuView.frame = CGRectMake(0.0, 0.0, self.menuView.bounds.size.width, self.menuView.bounds.size.height);
    [self.menuView setItemsTitle:self.itemTitles];
    __weak typeof(self) weakSelf = self;
    self.menuView.selectHandler = ^(YSMenuItemView *menuView, NSInteger selectIndex) {
        __strong typeof(self) self = weakSelf;
        self.needSelectAnimate = true;
        self.selectIndex = selectIndex;
    };
    
    self.containerView = [[UIScrollView alloc] init];
    [self.view addSubview:self.containerView];
    self.containerView.showsVerticalScrollIndicator = false;
    self.containerView.showsHorizontalScrollIndicator = false;
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.containerView.alwaysBounceVertical = false;
    self.containerView.alwaysBounceHorizontal = false;
    self.containerView.bounces = false;
    self.containerView.delegate = self;
    self.containerView.pagingEnabled = true;
    self.containerView.bounds = CGRectMake(0.0, CGRectGetMaxY(self.menuView.frame), self.view.bounds.size.width, self.view.bounds.size.height - self.menuView.bounds.size.height);
    
    CGSize size = self.containerView.bounds.size;
    NSInteger index = 0;
    for (UIViewController *vc in self.viewControllers) {
        [self addChildViewController:vc];
        [vc didMoveToParentViewController:self];
        [self.containerView addSubview:vc.view];
        vc.view.frame = CGRectMake(index * size.width, 0, size.width, size.height);
        index += 1;
    }
    self.containerView.contentSize = CGSizeMake(index * size.width, 0);
}

- (void)initializeShow {
    
    if (self.selectIndex == NSNotFound) {
        self.selectIndex = 0;
        [self.menuView chooseIndex:0];
    }
}

- (void)selectShowFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    [self willChanageIndexFrom:fromIndex toIndex:toIndex];
    
    CGSize containerSize = self.containerView.bounds.size;
    if (fromIndex == NSNotFound) {
        CGFloat offsetX = toIndex * containerSize.width;
        [self.containerView setContentOffset:CGPointMake(offsetX, 0) animated:false];
    } else {
        UIViewController *fromVC = [self.viewControllers objectAtIndex:fromIndex];
        UIViewController *toVC = [self.viewControllers objectAtIndex:toIndex];
        YSDirectionType direction = (toIndex - fromIndex > 0 ? YSDirectionType_Right : YSDirectionType_Left);
        CGRect frame = toVC.view.frame;
        frame.origin.x = fromVC.view.frame.origin.x + (direction == YSDirectionType_Right ? containerSize.width : -containerSize.width);
        toVC.view.frame = frame;
        [self.containerView setContentOffset: CGPointMake(frame.origin.x, 0) animated:true];
        [self.containerView bringSubviewToFront:toVC.view];
    }
}

- (void)handleContainerOffsetX:(CGFloat)offsetX {
    
    if (self.selectIndex == NSNotFound) {
        return;
    }
    CGFloat width = self.containerView.bounds.size.width;
    CGFloat currentOffset = self.selectIndex * width;
    CGFloat percent = (offsetX - currentOffset) / width;
    NSInteger toIndex = self.selectIndex;
    if (percent > 0) {
        toIndex += 1;
        toIndex = (toIndex < self.viewControllers.count ? toIndex : self.viewControllers.count - 1);
    } else {
        toIndex -= 1;
        toIndex = (toIndex >= 0 ? toIndex : 0);
        percent = -percent;
    }
    
    NSInteger changeIndex = ((NSInteger)offsetX)%((NSInteger)width);
    if (changeIndex == 0) {
        self.needSelectAnimate = false;
        self.selectIndex = ((NSInteger)offsetX)/((NSInteger)width);
        [self.containerView setContentOffset:CGPointMake(width * self.selectIndex, 0) animated:false];
        if (self.selectIndex == [self.menuView currentChooseIndex]) {
            [self.menuView reverseChooseIndex];
        } else {
            [self.menuView chooseIndex:self.selectIndex];
        }
        [self didChanageIndexFrom:self.preSelectIndex toIndex:self.selectIndex isCancel:false];
    }
    static NSInteger lastToIndex;
    if (lastToIndex != toIndex) {
        [self willChanageIndexFrom:self.selectIndex toIndex:toIndex];
        lastToIndex = toIndex;
    }
    [self updateMenuItemAppearanceFromIndex:self.selectIndex toIndex:toIndex percent:percent];
}

- (void)willChanageIndexFrom:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    if (self.incidentDelegate && [self.incidentDelegate respondsToSelector:@selector(segmentContainerViewController:willChangeIndexFrom:toIndex:)]) {
        [self.incidentDelegate segmentContainerViewController:self willChangeIndexFrom:fromIndex toIndex:toIndex];
    }
}

- (void)didChanageIndexFrom:(NSInteger)fromIndex toIndex:(NSInteger)toIndex isCancel:(BOOL)isCancel {
    
    if (self.incidentDelegate && [self.incidentDelegate respondsToSelector:@selector(segmentContainerViewController:didChangeIndexFrom:toIndex:isCanceled:)]) {
        [self.incidentDelegate segmentContainerViewController:self didChangeIndexFrom:fromIndex toIndex:toIndex isCanceled:isCancel];
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (!self.isPanProcessing) {
        return;
    }
    CGFloat offsetX = scrollView.contentOffset.x;
    [self handleContainerOffsetX:offsetX];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    UIViewController *toVC = [self.viewControllers objectAtIndex:self.selectIndex];
    CGRect frame = toVC.view.frame;
    CGFloat offsetX = self.selectIndex * scrollView.bounds.size.width;
    frame.origin.x = offsetX;
    toVC.view.frame = frame;
    [scrollView setContentOffset:CGPointMake(offsetX, 0) animated:false];
    [self didChanageIndexFrom:self.preSelectIndex toIndex:self.selectIndex isCancel:false];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    self.isPanProcessing = true;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    CGFloat offsetX = scrollView.contentOffset.x;
    CGSize size = scrollView.bounds.size;
    CGFloat currentOffset = self.selectIndex * size.width;
    CGFloat thresholdWidth = self.widthThreshold * size.width;
    NSInteger targetIndex = ((NSInteger)offsetX)/((NSInteger)size.width);
    NSInteger offsetW = offsetX - targetIndex * size.width;
    if (offsetX >= currentOffset) {
         // right
        targetIndex += (offsetW > thresholdWidth ? 1 : 0);
    } else {
        // left
        offsetW = size.width - offsetW;
        targetIndex += (offsetW > thresholdWidth ? 0 : 1);
    }
    
    self.needSelectAnimate = false;
    self.selectIndex = targetIndex;
    *targetContentOffset = CGPointMake(self.selectIndex * size.width, 0);
    BOOL isCancel = false;
    if (self.selectIndex == [self.menuView currentChooseIndex]) {
        [self.menuView reverseChooseIndex];
        isCancel = true;
    } else {
        [self.menuView chooseIndex:self.selectIndex];
    }
    [self didChanageIndexFrom:self.preSelectIndex toIndex:self.selectIndex isCancel:isCancel];
    self.isPanProcessing = false;
}

#pragma mark - getter/setter
- (void)setSelectIndex:(NSInteger)selectIndex {
    
    if (_selectIndex == selectIndex) {
        return;
    }
    self.preSelectIndex = _selectIndex;
    _selectIndex = selectIndex;
    if (self.needSelectAnimate) {
        [self selectShowFromIndex:self.preSelectIndex toIndex:self.selectIndex];
    } else {
        self.needSelectAnimate = true;
    }
}

- (void)setIsAllowPanInteractive:(BOOL)isAllowPanInteractive {
    
    _isAllowPanInteractive = isAllowPanInteractive;
    self.containerView.scrollEnabled = isAllowPanInteractive;
}

- (void)setIsPanProcessing:(BOOL)isPanProcessing {
    
    _isPanProcessing = isPanProcessing;
    self.menuView.userInteractionEnabled = !isPanProcessing;
}

@end
