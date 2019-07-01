//
//  YSMenuItemSliderView.m
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/27.
//  Copyright © 2019年 all. All rights reserved.
//

#import "YSMenuItemSliderView.h"

@interface YSMenuItemSliderView ()

@property (nonatomic, assign) NSInteger preSelectIndex;
@property (nonatomic, strong) NSArray *itemsSizeList;
@property (nonatomic, assign) CGFloat itemSizeMaxHeight;
@property (nonatomic, strong) UIScrollView *itemsView;
@property (nonatomic, strong) UIView *slider;
@property (nonatomic, weak) UIView *separateLine;

@end

@implementation YSMenuItemSliderView

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        _selectIndex = NSNotFound;
        _preSelectIndex = NSNotFound;
        _itemSizeMaxHeight = 0.0;
        
        _normalColor = [UIColor blackColor];
        _selectColor = [UIColor redColor];
        _itemFont = [UIFont boldSystemFontOfSize:15.0];
        _selectFontScale = 1.2;
        _itemWrapperWidthSpace = 16.0;
        _itemWrapperHeightSpace = 8.0;
        _itemSpace = 15.0;
        _sliderColor = [UIColor redColor];
        _sliderHeight = 2.0;
        _sliderOffsetTextBottom = 5.0;
        _sliderFitItemWidth = true;
        _separateLineColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        _separateLineHeight = 1.0;
        
        [self customView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.itemsView.frame = self.bounds;
    self.separateLine.frame = CGRectMake(0, self.bounds.size.height - self.separateLineHeight, self.bounds.size.width, self.separateLineHeight);
}

#pragma mark - override
- (void)setItemsTitle:(NSArray<NSString *> *)items {
    
    self.items = items;
}

- (void)chooseIndex:(NSInteger)index {
    
    self.selectIndex = index;
}


#pragma mark - public
- (void)setFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    
    UILabel *fromView = [self itemViewOfItemsViewByIndex:fromIndex];
    UILabel *toView = [self itemViewOfItemsViewByIndex:toIndex];
    
    CGRect fitItemFrame = [self getFitItemFrame:fromView];
    CGRect toViewOriginalFrame = [self getFitItemFrame:toView];
    
    CGFloat offsetX = (toViewOriginalFrame.origin.x - fitItemFrame.origin.x) * progress;
    CGFloat offswtWidth = (toViewOriginalFrame.size.width - fitItemFrame.size.width) * progress;
    
    CGRect frame = self.slider.frame;
    frame.origin.x = fitItemFrame.origin.x + offsetX;
    frame.size.width = fitItemFrame.size.width + offswtWidth;
    self.slider.frame = frame;
    
    CGFloat smallScale = self.selectFontScale - (self.selectFontScale - 1) * progress ;
    CGFloat bigScale = 1 + (self.selectFontScale - 1) * progress;
    fromView.transform = CGAffineTransformMakeScale(smallScale, smallScale);
    toView.transform = CGAffineTransformMakeScale(bigScale, bigScale);
    if (progress > 0.5) {
        fromView.textColor = self.normalColor;
        toView.textColor = self.selectColor;
    } else {
        fromView.textColor = self.selectColor;
        toView.textColor = self.normalColor;
    }
    NSLog(@"progress: %f, %@", progress, NSStringFromCGRect(self.slider.frame));
    if (progress >= 1.0) {
        self.selectIndex = toIndex;
    }
}
#pragma mark - incident
- (void)tapItem:(UITapGestureRecognizer *)tap {
    
    UIView *view = tap.view;
    NSInteger index = [self itemIndexOfItemsView:view];
    index = index;
    if (index >= 0 && index < self.items.count) {
        self.selectIndex = index;
        if (self.selectHandler) {
            self.selectHandler(self, self.selectIndex);
        }
    }
}
#pragma mark - http
#pragma mark - private
- (void)customView {
    
    self.itemsView = [self createScrollView];
    self.itemsView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.itemsView];
    
    self.slider = [[UIView alloc] initWithFrame:CGRectZero];
    self.slider.backgroundColor = self.sliderColor;
    self.slider.layer.cornerRadius = self.sliderCornerRadius;
    [self.itemsView addSubview:self.slider];
    
    UIView *lineView = [[UIView alloc] init];
    [self addSubview:lineView];
    lineView.backgroundColor = self.separateLineColor;
    self.separateLine = lineView;
}

- (UIScrollView *)createScrollView {
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    scrollView.showsVerticalScrollIndicator = false;
    scrollView.showsHorizontalScrollIndicator = false;
    scrollView.bounces = false;
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return scrollView;
}

- (void)createItemsViewWithSpeciatlWidth:(CGFloat)width {
    
    for (int i = 0; i < self.items.count; i++) {
        NSString *title = self.items[i];
        
        CGSize size = [self.itemsSizeList[i] CGSizeValue];
        CGFloat itemWidth = (width > 0.0 ? width : size.width);
        size = CGSizeMake(itemWidth + self.itemWrapperWidthSpace, self.itemSizeMaxHeight + self.itemWrapperHeightSpace);
        CGFloat originX = 0.0 + self.itemSpace;
        UIView *lastView = self.itemsView.subviews.lastObject;
        if (lastView && [lastView isKindOfClass:[UILabel class]]) {
            originX = CGRectGetMaxX(self.itemsView.subviews.lastObject.frame) + self.itemSpace;
        }
        CGFloat originY = (self.bounds.size.height - size.height) * 0.5;
        CGRect frame = CGRectMake(originX, originY, size.width, size.height);
        
        UILabel *itemLabel = [self createItemLabelWithTitle:title];
        itemLabel.textColor = self.normalColor;
        itemLabel.font = self.itemFont;
        itemLabel.userInteractionEnabled = true;
        [itemLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapItem:)]];
        [self.itemsView addSubview:itemLabel];
        itemLabel.frame = frame;
    }
    
    UIView *lastItemView = self.itemsView.subviews.lastObject;
    UIView *firstItemView = [self itemViewOfItemsViewByIndex:0];
    CGFloat maxX = CGRectGetMaxX(lastItemView.frame) + self.itemSpace;
    self.itemsView.contentSize = CGSizeMake(maxX, 0);
    self.slider.frame = CGRectMake(firstItemView.frame.origin.x, CGRectGetMaxY(firstItemView.frame) + self.sliderOffsetTextBottom, firstItemView.bounds.size.width, self.sliderHeight);
}

- (UILabel *)createItemLabelWithTitle:(NSString *)title {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
}

- (void)setFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    if (fromIndex < 0 || fromIndex >= self.items.count) {
        fromIndex = 0;
    }
    
    UILabel *fromView = [self itemViewOfItemsViewByIndex:fromIndex];
    UILabel *toView = [self itemViewOfItemsViewByIndex:toIndex];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect itemFitFrame = [self getFitItemFrame:toView];
        self.slider.frame = CGRectMake(itemFitFrame.origin.x, self.slider.frame.origin.y, itemFitFrame.size.width, self.sliderHeight);
        NSLog(@"anim: %@", NSStringFromCGRect(self.slider.frame));
        fromView.transform = CGAffineTransformIdentity;
        fromView.textColor = self.normalColor;
        toView.transform = CGAffineTransformMakeScale(self.selectFontScale, self.selectFontScale);
        toView.textColor = self.selectColor;
    } completion:^(BOOL finished) {
        
    }];
    [self adjustItemInCenter];
}

// 调整选中的item居中
- (void)adjustItemInCenter {
    
    CGFloat width = [self getSelfWidth];
    NSInteger index = self.selectIndex;
    UIView *selectItemView = [self itemViewOfItemsViewByIndex:index];
    CGFloat centerX = selectItemView.center.x;
    CGPoint contentOffset = CGPointZero;
    CGFloat contentSizeWidth = self.itemsView.contentSize.width;
    if (centerX <= width * 0.5) {
        contentOffset = CGPointZero;
    } else if (centerX >= contentSizeWidth - width * 0.5) {
        CGFloat offsetX = contentSizeWidth - width;
        // 小于一屏的情况
        if (offsetX < 0) {
            offsetX = 0.0;
        }
        contentOffset = CGPointMake(offsetX, 0.0);
    } else {
        contentOffset = CGPointMake(selectItemView.center.x - width * 0.5, 0.0);
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.itemsView.contentOffset = contentOffset;
    }];
}


- (CGFloat)getSelfWidth {
    
    CGFloat width = self.bounds.size.width;
    if (width <= 0.0) {
        width = [UIScreen mainScreen].bounds.size.width;
    }
    return width;
}

- (CGRect)getFitItemFrame:(UIView *)itemView {
    
    // 获取transform前的坐标
    CGRect frame = itemView.frame;
    if (itemView.transform.a > 0.0 || itemView.transform.d > 0.0) {
        CGFloat width = frame.size.width / itemView.transform.a;
        CGFloat originX = frame.origin.x + (frame.size.width - width) * 0.5;
        frame.origin.x = originX;
        frame.size.width = width;
    }
    if (self.sliderFitItemWidth) {
        return frame;
    } else {
        NSInteger index = [self itemIndexOfItemsView:itemView];
        if (index == NSNotFound) {
            return CGRectZero;
        }
        CGSize textSize = [self.itemsSizeList[index] CGSizeValue];
        CGSize fitSize = CGSizeMake(textSize.width + self.itemWrapperWidthSpace , self.itemSizeMaxHeight + self.itemWrapperHeightSpace);
        CGFloat offsetW = frame.size.width - fitSize.width;
        return CGRectMake(frame.origin.x + offsetW * 0.5, frame.origin.y, fitSize.width, fitSize.height);
    }
}

- (NSInteger)itemIndexOfItemsView:(UIView *)itemView {
    
    //第一个为slider,不是item
    NSInteger index = [self.itemsView.subviews indexOfObject:itemView];
    if (index != NSNotFound && [itemView isKindOfClass:[UILabel class]]) {
        index -= 1;
    }
    return index;
}

- (UILabel *)itemViewOfItemsViewByIndex:(NSInteger)index {
    
    UILabel *label = nil;
    if (index >= 0 && index < self.items.count) {
        label = [self.itemsView.subviews objectAtIndex:index + 1];
    }
    return label;
}

#pragma mark - delegate
#pragma mark - getter/setter
- (void)setSelectIndex:(NSInteger)selectIndex {
    
    if (selectIndex < 0 || selectIndex > self.items.count || self.selectIndex == selectIndex)  {
        return;
    }
    self.preSelectIndex = _selectIndex;
    _selectIndex = selectIndex;
    [self setFromIndex:self.preSelectIndex toIndex:self.selectIndex];
}

- (void)setItems:(NSArray<NSString *> *)items {
    
    _items = items;
    NSMutableArray *list = [NSMutableArray array];
    CGFloat totalWidth = 0.0;
    for (NSString *str in items) {
        CGSize size = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 0.0) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: self.itemFont} context:nil].size;
        [list addObject:[NSValue valueWithCGSize:size]];
        totalWidth += (size.width + self.itemSpace + self.itemWrapperWidthSpace);
        // 获取字形中最高的作为全部标准
        if (size.height > self.itemSizeMaxHeight) {
            self.itemSizeMaxHeight = size.height;
        }
    }
    totalWidth += self.itemSpace;
    self.itemsSizeList = list;
    CGFloat width = [self getSelfWidth];
    if (totalWidth < width && self.isEqualItem) {
        NSInteger count = self.items.count;
        CGFloat itemWidth = ([self getSelfWidth] - (count + 1) * self.itemSpace - count * self.itemWrapperWidthSpace) / count;
        [self createItemsViewWithSpeciatlWidth:itemWidth];
    } else {
        [self createItemsViewWithSpeciatlWidth:-1.0];
    }
}

- (void)setSliderColor:(UIColor *)sliderColor {
    _sliderColor = sliderColor;
    self.slider.backgroundColor = sliderColor;
}

- (void)setSliderHeight:(CGFloat)sliderHeight {
    _sliderHeight = sliderHeight;
    CGRect frame = self.slider.frame;
    frame.size.height = sliderHeight;
    self.slider.frame = frame;
}

- (void)setSliderCornerRadius:(CGFloat)sliderCornerRadius {
    _sliderCornerRadius = sliderCornerRadius;
    self.slider.layer.cornerRadius = sliderCornerRadius;
}

- (void)setSeparateLineColor:(UIColor *)separateLineColor {
    _separateLineColor = separateLineColor;
    self.separateLine.backgroundColor = separateLineColor;
}

- (void)setSeparateLineHeight:(CGFloat)separateLineHeight {
    _separateLineHeight = separateLineHeight;
    [self setNeedsLayout];
}
@end
