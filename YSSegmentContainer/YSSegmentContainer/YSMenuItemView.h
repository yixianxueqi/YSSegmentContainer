//
//  YSMenuItemView.h
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/27.
//  Copyright © 2019年 all. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 The tabView parentClass.
 It's an Abstract class, subClass should implement these menthods;
 */
@interface YSMenuItemView : UIView

@property (nonatomic, copy) void(^selectHandler)(YSMenuItemView *menuView, NSInteger selectIndex);

- (void)setItemsTitle:(NSArray<NSString *> *)items;
- (void)chooseIndex:(NSInteger)index;
- (void)setFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress;

@end
