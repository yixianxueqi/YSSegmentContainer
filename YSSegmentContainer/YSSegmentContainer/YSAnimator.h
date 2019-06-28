//
//  YSAnimator.h
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/27.
//  Copyright © 2019年 all. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YSTransitionDirection) {
    YSTransitionDirection_Left,
    YSTransitionDirection_Right
};

/**
 Implement the animations.
 */
@interface YSAnimator : NSObject<UIViewControllerAnimatedTransitioning>

- (instancetype)initWithDirection:(YSTransitionDirection)direction;

@end

