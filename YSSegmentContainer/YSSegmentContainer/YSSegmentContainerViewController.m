//
//  YSSegmentContainerViewController.m
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/27.
//  Copyright © 2019年 all. All rights reserved.
//

#import "YSSegmentContainerViewController.h"
#import "YSMenuItemView.h"

static NSTimeInterval kDuration = 0.25;

typedef NS_ENUM(NSInteger, YSDirectionType) {
    YSDirectionType_Left = -1,
    YSDirectionType_Right = 1
};

@interface YSSegmentContainerViewController ()

@property (nonatomic, readwrite) NSInteger selectIndex;

@property (nonatomic, strong) NSArray *itemTitles;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, assign) CGPoint originXY;
@property (nonatomic, assign) BOOL needSelectAnimate;
@property (nonatomic, assign) BOOL isPanProcessing;
@property (nonatomic, assign) NSInteger preSelectIndex;

@end

@implementation YSSegmentContainerViewController

#pragma mark - lifeCycle
- (instancetype)init {
    self = [super init];
    if (self) {
        _selectIndex = NSNotFound;
        _preSelectIndex = NSNotFound;
        _isAllowPanInteractive = true;
        _widthThreshold = 0.5;
        _needSelectAnimate = true;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepareData];
    [self customView];
    [self addPan];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initializeShow];
    self.pan.enabled = self.isAllowPanInteractive;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.containerView.frame = CGRectMake(0.0, CGRectGetMaxY(self.menuView.frame), self.view.bounds.size.width, self.view.bounds.size.height - self.menuView.bounds.size.height);
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        self.selectIndex = selectIndex;
    };
    
    self.containerView = [[UIView alloc] init];
    [self.view addSubview:self.containerView];
    self.containerView.clipsToBounds = false;
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.containerView.bounds = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
    for (UIViewController *vc in self.viewControllers) {
        [self addChildViewController:vc];
        [vc didMoveToParentViewController:self];
    }
    self.originXY = self.containerView.bounds.origin;
}

- (void)initializeShow {
    
    if (self.selectIndex == NSNotFound) {
        self.selectIndex = 0;
        [self.menuView chooseIndex:0];
    }
}

- (void)selectShowFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    [self willChanageIndexFrom:fromIndex toIndex:toIndex];
    
    if (fromIndex == NSNotFound) {
        UIViewController *toVC = [self.viewControllers objectAtIndex:toIndex];
        [self addChildViewController:toVC];
        [self.containerView addSubview:toVC.view];
        toVC.view.frame = self.containerView.bounds;
        [toVC didMoveToParentViewController:self];
        [self didChanageIndexFrom:fromIndex toIndex:toIndex isCancel:false];
    } else {
        UIViewController *fromVC = [self.viewControllers objectAtIndex:fromIndex];
        UIViewController *toVC = [self.viewControllers objectAtIndex:toIndex];
        
        YSDirectionType direction = fromIndex > toIndex ?  YSDirectionType_Left : YSDirectionType_Right;
        CGFloat width = self.containerView.bounds.size.width;
        toVC.view.transform = (direction == YSDirectionType_Right ? CGAffineTransformMakeTranslation(width, 0) : CGAffineTransformMakeTranslation(-width, 0));
        fromVC.view.transform = CGAffineTransformIdentity;
        [self transitionFromViewController:fromVC toViewController:toVC duration:kDuration options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
            fromVC.view.transform = direction > 0 ? CGAffineTransformMakeTranslation(-width, 0) : CGAffineTransformMakeTranslation(width, 0);
            toVC.view.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            fromVC.view.transform = CGAffineTransformIdentity;
            toVC.view.transform = CGAffineTransformIdentity;
            [self didChanageIndexFrom:fromIndex toIndex:toIndex isCancel:false];
        }];
    }
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

#pragma mark - pan
- (void)addPan {
    
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:self.pan];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    
    if (!self.isPanProcessing) {
        if (self.viewControllers.count < 2) {
            return;
        }
        CGFloat velocityX = [pan velocityInView:self.view].x;
        BOOL rightFlag = (velocityX <= 0.0 && self.selectIndex + 1 > self.viewControllers.count);
        BOOL leftFlag = (velocityX >= 0.0 && self.selectIndex - 1 < 0);
        if (leftFlag || rightFlag) {
            return;
        }
    }
    // 注意此处方向,手指向左滑动即右侧视图显现
    CGFloat translate = -([pan translationInView:self.view].x);
    CGSize containerSize = self.containerView.bounds.size;
    CGFloat progress = translate / containerSize.width;
    
    NSInteger toIndex = (progress > 0 ? self.selectIndex + 1 : self.selectIndex - 1);
    if (toIndex < 0 || toIndex >= self.viewControllers.count) {
        UIViewController *currentVC = [self.viewControllers objectAtIndex:self.selectIndex];
        for (UIView *subView in self.containerView.subviews) {
            if (![subView isEqual:currentVC.view]) {
                subView.frame = self.containerView.bounds;
                [subView removeFromSuperview];
            }
        }
        self.isPanProcessing = false;
        return;
    }
    static NSInteger firstToIndex = NSNotFound;
    
    self.isPanProcessing = true;
    if (self.containerView.subviews.count <= 1) {
        [self handlePanBegan];
    }
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            /*
             当子视图存在类似于tableview时,手势初始识别可能在tableview上而不在此，导致此方法不一定进入
             因此下列方法放在外部
             self.isPanProcessing = true;
             [self handlePanBegan];
             */
        }break;
        case UIGestureRecognizerStateChanged: {
            CGRect bounds = [self getContainerViewOriginalBounds];
            CGFloat offsetW = containerSize.width * progress;
            bounds.origin.x += offsetW;
            self.containerView.bounds = bounds;
            [self updateMenuItemAppearanceFromIndex:self.selectIndex toIndex:toIndex percent:progress];
            if (firstToIndex != toIndex) {
                [self willChanageIndexFrom:self.selectIndex toIndex:toIndex];
                firstToIndex = toIndex;
            }
        }break;
        case UIGestureRecognizerStatePossible: NSLog(@"Possible"); break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded: {
            self.isPanProcessing = false;
            if (progress >= fabs(self.widthThreshold) || progress <= -fabs(self.widthThreshold)) {
                [self panFinshByProgress:progress];
            } else {
                [self panCancelByProgress:progress];
            }
            firstToIndex = NSNotFound;
        }break;
        default:
            break;
    }
}

- (void)handlePanBegan {
    
    NSInteger preIndex = self.selectIndex - 1;
    NSInteger nextIndex = self.selectIndex + 1;
    CGSize contentSize = self.containerView.bounds.size;
    
    if (preIndex >= 0) {
        UIViewController *preVC = [self.viewControllers objectAtIndex:preIndex];
        [self.containerView addSubview: preVC.view];
        preVC.view.frame = CGRectMake(-contentSize.width, 0, contentSize.width, contentSize.height);
    }
    if (nextIndex < self.viewControllers.count) {
        UIViewController *nextVC = [self.viewControllers objectAtIndex:nextIndex];
        [self.containerView addSubview: nextVC.view];
        nextVC.view.frame = CGRectMake(contentSize.width, 0.0, contentSize.width, contentSize.height);
    }
}

- (void)panCancelByProgress:(CGFloat)progress {
    
    YSDirectionType direction = progress > 0.0 ? YSDirectionType_Right : YSDirectionType_Left;
    NSTimeInterval duration = kDuration * (1 - fabs(progress)) * 2.0;
    NSInteger preIndex = self.selectIndex - 1;
    NSInteger nextIndex = self.selectIndex + 1;
    UIViewController *preVC = nil;
    if (preIndex >= 0) {
        preVC = [self.viewControllers objectAtIndex:preIndex];
    }
    UIViewController *nextVC = nil;
    if (nextIndex < self.viewControllers.count) {
        nextVC = [self.viewControllers objectAtIndex:nextIndex];
    }
    
    [self.menuView reverseChooseIndex];
    [UIView animateWithDuration:duration animations:^{
        CGRect bounds = [self getContainerViewOriginalBounds];
        self.containerView.bounds = bounds;
    } completion:^(BOOL finished) {
        [preVC.view removeFromSuperview];
        [nextVC.view removeFromSuperview];
        preVC.view.frame = self.containerView.bounds;
        nextVC.view.frame = self.containerView.bounds;
        [self didChanageIndexFrom:self.selectIndex toIndex:(direction == YSDirectionType_Right ? nextIndex : preIndex) isCancel:true];
    }];
}

- (void)panFinshByProgress:(CGFloat)progress {
    
    YSDirectionType direction = (progress > 0 ? YSDirectionType_Right : YSDirectionType_Left);
    NSTimeInterval duration = kDuration * (1 - fabs(progress)) * 2.0;
    NSInteger preIndex = self.selectIndex - 1;
    NSInteger nextIndex = self.selectIndex + 1;
    UIViewController *preVC = nil;
    if (preIndex >= 0) {
        preVC = [self.viewControllers objectAtIndex:preIndex];
    }
    UIViewController *nextVC = nil;
    if (nextIndex < self.viewControllers.count) {
        nextVC = [self.viewControllers objectAtIndex:nextIndex];
    }
    
    UIViewController *currentVC = [self.viewControllers objectAtIndex:self.selectIndex];
    CGSize containerSize = self.containerView.bounds.size;
    CGRect bounds = [self getContainerViewOriginalBounds];
    bounds.origin.x += (direction * containerSize.width);
    NSInteger newSelectIndex = self.selectIndex + direction;
    
    [self.menuView chooseIndex:newSelectIndex];
    [UIView animateWithDuration:duration animations:^{
        self.containerView.bounds = bounds;
    } completion:^(BOOL finished) {
        [currentVC.view removeFromSuperview];
        self.containerView.bounds = [self getContainerViewOriginalBounds];
        if (direction == YSDirectionType_Left) {
            [nextVC.view removeFromSuperview];
            preVC.view.frame = self.containerView.bounds;
        } else {
            [preVC.view removeFromSuperview];
            nextVC.view.frame = self.containerView.bounds;
        }
        preVC.view.frame = self.containerView.bounds;
        nextVC.view.frame = self.containerView.bounds;
        self.needSelectAnimate = false;
        self.selectIndex = newSelectIndex;
        [self didChanageIndexFrom:self.preSelectIndex toIndex:self.selectIndex isCancel:false];
    }];
}

- (CGRect)getContainerViewOriginalBounds {
    
    return CGRectMake(self.originXY.x, self.originXY.y, self.containerView.bounds.size.width, self.containerView.bounds.size.height);
}

#pragma mark - delegate
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
    self.pan.enabled = isAllowPanInteractive;
}

- (void)setIsPanProcessing:(BOOL)isPanProcessing {
    
    _isPanProcessing = isPanProcessing;
    self.menuView.userInteractionEnabled = !isPanProcessing;
}

@end
