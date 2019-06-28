//
//  YSIntercativeControl.m
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/27.
//  Copyright © 2019年 all. All rights reserved.
//

#import "YSIntercativeControl.h"
#import "YSTransitionContext.h"

@interface YSIntercativeControl ()

@property (nonatomic, weak) YSTransitionContext *context;

@end

@implementation YSIntercativeControl

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    self.context = (YSTransitionContext *)transitionContext;
    [self.context activateInteractiveTransition];
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    
    [self.context updateInteractiveTransition:percentComplete];
}

- (void)cancelInteractiveTransition {
    
    [self.context cancelInteractiveTransition];
}

- (void)finishInteractiveTransition {
    
    [self.context finishInteractiveTransition];
}

@end
