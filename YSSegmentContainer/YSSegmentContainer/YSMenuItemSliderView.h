//
//  YSMenuItemSliderView.h
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/27.
//  Copyright © 2019年 all. All rights reserved.
//

#import "YSMenuItemView.h"


@interface YSMenuItemSliderView : YSMenuItemView

@property (nonatomic, strong) NSArray<NSString *> *items;
@property (nonatomic, assign) NSInteger selectIndex;
/*
 When items total width less than screen width, whether full screen.
 default true.
 */
@property (nonatomic, assign) BOOL isEqualItem;

// default black color
@property (nonatomic, strong) UIColor *normalColor;
// default Red color
@property (nonatomic, strong) UIColor *selectColor;
// default boldSystemFontOfSize:15.0
@property (nonatomic, strong) UIFont *itemFont;
// default 1.2
@property (nonatomic, assign) CGFloat selectFontScale;
// default 16.0
@property (nonatomic, assign) CGFloat itemWrapperWidthSpace;
// default 8.0
@property (nonatomic, assign) CGFloat itemWrapperHeightSpace;
// the space of leading,trailing,items between space, default 15.0
@property (nonatomic, assign) CGFloat itemSpace;

// defalult Red color
@property (nonatomic, strong) UIColor *sliderColor;
// default 2.0
@property (nonatomic, assign) CGFloat sliderHeight;
// default 1.0
@property (nonatomic, assign) CGFloat sliderCornerRadius;
// default 5.0
@property (nonatomic, assign) CGFloat sliderOffsetTextBottom;
// adjust slider width by additional width,  default 0.0
@property (nonatomic, assign) CGFloat sliderExtWidth;
// whether fixed width, default false
@property (nonatomic, assign) BOOL sliderUseFiexedWidth;
// default 30.0,
@property (nonatomic, assign) CGFloat sliderFixedWidth;
/*
 whether slider view fit item width, default true.
 true: fit item Width, false: fit item's text width(textWidth+itemWrapperWidthSpace)
 */
@property (nonatomic, assign) BOOL sliderFitItemWidth;


// default [UIColor colorWithWhite:0.9 alpha:1.0]
@property (nonatomic, strong) UIColor *separateLineColor;
// default 1.0
@property (nonatomic, assign) CGFloat separateLineHeight;

@end

