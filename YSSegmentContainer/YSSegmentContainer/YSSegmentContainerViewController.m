//
//  YSSegmentContainerViewController.m
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/27.
//  Copyright © 2019年 all. All rights reserved.
//

#import "YSSegmentContainerViewController.h"
#import "YSTransitionContext.h"
#import "YSMenuItemView.h"

@interface YSSegmentContainerViewController ()

@property (nonatomic, readwrite) NSInteger selectIndex;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSArray *itemTitles;

@property (nonatomic, assign) NSInteger preSelectIndex;
@property (nonatomic, assign) BOOL shouldReserve;

@property (nonatomic, strong) YSTransitionContext *context;

@end

@implementation YSSegmentContainerViewController

#pragma mark - lifeCycle
- (instancetype)init {
    self = [super init];
    if (self) {
        _selectIndex = NSNotFound;
        _preSelectIndex = NSNotFound;
        _interactive = false;
        _interativePanPercent = 0.5;
        _isAllowPanInteractive = true;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepareData];
    [self customView];
    [self addNotification];
    [self addPanGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initializeShow];
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

- (void)reverseTransition {
    
    self.shouldReserve = true;
    self.selectIndex = self.preSelectIndex;
}

- (void)updateMenuItemAppearanceByPercent:(CGFloat)percent {
    
    [self.menuView setFromIndex:self.preSelectIndex toIndex:self.selectIndex progress:percent];
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
    self.containerView.backgroundColor = [UIColor whiteColor];
    
}

- (void)addNotification {
    
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:YSContainerTransitionEndNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(self) self = weakSelf;
        self.context = nil;
        self.menuView.userInteractionEnabled = true;
        
        if (self.incidentDelegate && [self.incidentDelegate respondsToSelector:@selector(segmentContainerViewController:didChangeIndexFrom:toIndex:isCanceled:)]) {
            NSDictionary *userInfo = note.userInfo;
            NSInteger fromIndex = [self.viewControllers indexOfObject:[userInfo objectForKey:@"fromVC"]];
            NSInteger toIndex = [self.viewControllers indexOfObject:[userInfo objectForKey:@"toVC"]];
            BOOL isCancel = [[userInfo objectForKey:@"isCancel"] boolValue];
            [self.incidentDelegate segmentContainerViewController:self didChangeIndexFrom:fromIndex toIndex:toIndex isCanceled:isCancel];
        }
    }];
}

- (void)addPanGesture {
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:pan];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    
    if (!self.isAllowPanInteractive) {
        return;
    }
    
    if (self.viewControllers.count < 2 || self.delegate == nil) {
        return;
    }
    CGFloat translate = fabs([pan translationInView:self.view].x);
    CGFloat progress = translate / self.view.bounds.size.width;
    id<YSSegmentContainerViewControllerDelegate> transistion = self.delegate;
    UIPercentDrivenInteractiveTransition *intercative = nil;
    if (transistion && [transistion respondsToSelector:@selector(containerViewControllerTransitionInContainerViewController:animator:)]) {
        intercative = [transistion containerViewControllerTransitionInContainerViewController:self animator:nil];
    }
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            self.interactive = true;
            CGFloat velocityX = [pan velocityInView:self.view].x;
            if (velocityX < 0) {
                if (self.selectIndex < self.viewControllers.count - 1) {
                    self.selectIndex += 1;
                }
            } else {
                if (self.selectIndex > 0) {
                    self.selectIndex -= 1;
                }
            }
        }break;
        case UIGestureRecognizerStateChanged:{
            [intercative updateInteractiveTransition:progress];
        }break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:{
            self.interactive = false;
            if (progress > self.interativePanPercent) {
                [intercative finishInteractiveTransition];
            } else {
                [intercative cancelInteractiveTransition];
            }
        }break;
        default:
            break;
    }
}

- (void)initializeShow {
    
    if (self.selectIndex == NSNotFound) {
        self.selectIndex = 0;
        [self.menuView chooseIndex:0];
    }
}

- (void)transitionViewControllerFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)index {
    
    if (self.viewControllers.count <= 0 || fromIndex < 0 || index < 0 || index >= self.viewControllers.count || (fromIndex >= self.viewControllers.count && fromIndex != NSNotFound)) {
        return;
    }
    
    if (self.incidentDelegate && [self.incidentDelegate respondsToSelector:@selector(segmentContainerViewController:willChangeIndexFrom:toIndex:)]) {
        [self.incidentDelegate segmentContainerViewController:self willChangeIndexFrom:fromIndex toIndex:index];
    }
    
    if (fromIndex == NSNotFound) {
        [self addChildViewController:self.selectVC];
        [self.selectVC didMoveToParentViewController:self];
        [self.containerView addSubview:self.selectVC.view];
        self.selectVC.view.frame = self.containerView.bounds;
        
        if (self.incidentDelegate && [self.incidentDelegate respondsToSelector:@selector(segmentContainerViewController:didChangeIndexFrom:toIndex:isCanceled:)]) {
            [self.incidentDelegate segmentContainerViewController:self didChangeIndexFrom:fromIndex toIndex:index isCanceled:false];
        }
        return;
    }
    if (self.delegate) {
        self.menuView.userInteractionEnabled = false;
        UIViewController *preVC = self.viewControllers[fromIndex];
        UIViewController *toVC = self.viewControllers[index];
        self.context = [[YSTransitionContext alloc] initWithContainerViewController:self containerView:self.containerView fromViewController:preVC toViewController:toVC];
        if (self.interactive) {
            [self.context startInteractiveTransitionWithDelegate:self.delegate];
        } else {
            [self.context startUnInteractiveTransitionWithDelegate:self.delegate];
        }
    } else {
        UIViewController *preVC = self.viewControllers[fromIndex];
        [preVC willMoveToParentViewController:nil];
        [preVC.view removeFromSuperview];
        [preVC removeFromParentViewController];
        
        UIViewController *curVC = self.viewControllers[index];
        [self addChildViewController:curVC];
        [curVC didMoveToParentViewController:self];
        [self.containerView addSubview:curVC.view];
        curVC.view.frame = self.containerView.bounds;
    }
}

- (UIViewController *)selectVC {
    
    if (self.viewControllers.count <=0 || self.selectIndex < 0 || self.selectIndex >= self.viewControllers.count) {
        return nil;
    }
    return self.viewControllers[self.selectIndex];
}

#pragma mark - delegate
#pragma mark - getter/setter
- (void)setSelectIndex:(NSInteger)selectIndex {
    
    if (_selectIndex == selectIndex) {
        return;
    }
    self.preSelectIndex = _selectIndex;
    _selectIndex = selectIndex;
    if (self.shouldReserve) {
        self.shouldReserve = false;
    } else {
        [self transitionViewControllerFromIndex:self.preSelectIndex toIndex:selectIndex];
    }
}



@end
