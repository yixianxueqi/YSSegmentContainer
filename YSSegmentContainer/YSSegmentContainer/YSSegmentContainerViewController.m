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
@property (nonatomic, assign) CGRect originBounds;
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
    self.originBounds = self.containerView.bounds;
}

- (void)initializeShow {
    
    if (self.selectIndex == NSNotFound) {
        self.selectIndex = 0;
        [self.menuView chooseIndex:0];
    }
}

- (void)selectShowFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    if (fromIndex == NSNotFound) {
        UIViewController *toVC = [self.viewControllers objectAtIndex:toIndex];
        [self addChildViewController:toVC];
        [self.containerView addSubview:toVC.view];
        toVC.view.frame = self.containerView.bounds;
        [toVC didMoveToParentViewController:self];
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
        }];
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
    CGFloat translate = -([pan translationInView:self.view].x);
    CGFloat progress = translate / self.view.bounds.size.width;
    CGFloat width = self.containerView.bounds.size.width;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            self.isPanProcessing = true;
            [self handlePanBegan];
        }break;
        case UIGestureRecognizerStateChanged: {
            CGRect bounds = self.originBounds;
            CGFloat offsetW = width * progress;
            bounds.origin.x += offsetW;
            self.containerView.bounds = bounds;
            NSInteger toIndex = (progress > 0 ? self.selectIndex + 1 : self.selectIndex - 1);
            [self updateMenuItemAppearanceFromIndex:self.selectIndex toIndex:toIndex percent:progress];
        }break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded: {
            self.isPanProcessing = false;
            if (progress > 0.4 || progress < -0.4) {
                [self panFinshByProgress:progress];
            } else {
                [self panCancelByProgress:progress];
            }
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
    
    [UIView animateWithDuration:duration animations:^{
        self.containerView.bounds = self.originBounds;
    } completion:^(BOOL finished) {
        [preVC.view removeFromSuperview];
        [nextVC.view removeFromSuperview];
        preVC.view.frame = self.containerView.bounds;
        nextVC.view.frame = self.containerView.bounds;
        [self.menuView reverseChooseIndex];
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
    
    CGRect bounds = self.originBounds;
    bounds.origin.x += (direction * bounds.size.width);
    [UIView animateWithDuration:duration animations:^{
        self.containerView.bounds = bounds;
    } completion:^(BOOL finished) {
        [currentVC.view removeFromSuperview];
        self.containerView.bounds = self.originBounds;
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
        self.selectIndex += (direction);
        [self.menuView chooseIndex:self.selectIndex];
    }];
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
