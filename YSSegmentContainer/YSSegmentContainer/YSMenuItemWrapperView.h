//
//  YSMenuItemWrapperView.h
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/27.
//  Copyright © 2019年 all. All rights reserved.
//

#import "YSMenuItemView.h"

/**
 A wrapper border style tabView.
 */
@interface YSMenuItemWrapperView : YSMenuItemView

@property (nonatomic, strong) NSArray<NSString *> *items;
@property (nonatomic, assign) NSInteger selectIndex;
/*
 When items total width less than screen width, whether full screen.
 default true.
 */
@property (nonatomic, assign) BOOL isEqualItem;

// default black color
@property (nonatomic, strong) UIColor *normalColor;
// default white color
@property (nonatomic, strong) UIColor *selectColor;
// default boldSystemFontOfSize:15.0
@property (nonatomic, strong) UIFont *itemFont;
// default RGBA(89, 126, 247, 1.0)
@property (nonatomic, strong) UIColor *selectBGColor;
/*
 whether selectBG view fit item width, default true.
 true: fit item Width, false: fit item's text width
 */
@property (nonatomic, assign) BOOL selectBGFitItemWidth;
// default 16.0
@property (nonatomic, assign) CGFloat itemWrapperWidthSpace;
// default 8.0
@property (nonatomic, assign) CGFloat itemWrapperHeightSpace;
// the space of leading,trailing,items between space, default 15.0
@property (nonatomic, assign) CGFloat itemSpace;

// default [UIColor colorWithWhite:0.9 alpha:1.0]
@property (nonatomic, strong) UIColor *separateLineColor;
// default 1.0
@property (nonatomic, assign) CGFloat separateLineHeight;

@end

