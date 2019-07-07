//
//  YSMenuItemWrapperView.m
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/27.
//  Copyright © 2019年 all. All rights reserved.
//

#import "YSMenuItemWrapperView.h"

@interface YSMenuItemWrapperView ()<UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger preSelectIndex;
@property (nonatomic, strong) NSArray *itemsSizeList;
@property (nonatomic, assign) CGFloat itemSizeMaxHeight;
@property (nonatomic, strong) UIScrollView *itemsView;

@property (nonatomic, strong) UIScrollView *selectItemsView;
@property (nonatomic, strong) UIView *selectMaskView;

@property (nonatomic, weak) UIView *separateLine;

@end

@implementation YSMenuItemWrapperView

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        _selectIndex = NSNotFound;
        _preSelectIndex = NSNotFound;
        _itemSizeMaxHeight = 0.0;
        
        _normalColor = [UIColor blackColor];
        _selectColor = [UIColor whiteColor];
        _itemFont = [UIFont boldSystemFontOfSize:15.0];
        _selectBGColor = [UIColor colorWithRed:89/255.0 green:126/255.0 blue:247/255.0 alpha:1.0];
        _itemWrapperWidthSpace = 16.0;
        _itemWrapperHeightSpace = 8.0;
        _itemSpace = 15.0;
        _separateLineColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        _separateLineHeight = 1.0;
        _selectBGFitItemWidth = true;
        
        [self customView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.itemsView.frame = self.bounds;
    self.selectItemsView.frame = self.bounds;
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
    
    UILabel *fromView = [self.selectItemsView.subviews objectAtIndex:fromIndex];
    UILabel *toView = [self.selectItemsView.subviews objectAtIndex:toIndex];
    
    CGRect fromRect = [self getFitItemFrame:fromView];
    CGRect toRect = [self getFitItemFrame:toView];
    
    CGFloat offsetX = (toRect.origin.x - fromRect.origin.x) * progress;
    CGFloat offswtWidth = (toRect.size.width - fromRect.size.width) * progress;
    
    self.maskView.frame = CGRectMake(fromRect.origin.x + offsetX, toRect.origin.y, fromRect.size.width + offswtWidth, toRect.size.height);
    
    if (progress >= 1.0) {
        self.selectIndex = toIndex;
    }
}

- (void)reverseChooseIndex {
    
    [self setFromIndex:self.selectIndex toIndex:self.selectIndex];
}

#pragma mark - incident
- (void)tapItem:(UITapGestureRecognizer *)tap {
    
    UIView *view = tap.view;
    NSInteger index = [self.itemsView.subviews indexOfObject:view];
    index = index;
    if (index >= 0 && index < self.items.count) {
        self.selectIndex = index;
        if (self.selectHandler) {
            self.selectHandler(self, self.selectIndex);
        }
    }
}

#pragma mark - private
- (void)customView {
    
    self.itemsView = [self createScrollView];
    self.itemsView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.itemsView];
    
    self.selectItemsView = [self createScrollView];
    self.selectItemsView.backgroundColor = self.selectBGColor;
    self.selectItemsView.userInteractionEnabled = false;
    [self addSubview:self.selectItemsView];
    
    self.maskView = [[UIView alloc] initWithFrame:CGRectZero];
    self.maskView.backgroundColor = [UIColor redColor];
    self.selectItemsView.maskView = self.maskView;
    
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
    scrollView.delegate = self;
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
        CGFloat originX = CGRectGetMaxX(self.itemsView.subviews.lastObject.frame) + self.itemSpace;
        CGFloat originY = (self.bounds.size.height - size.height) * 0.5;
        CGRect frame = CGRectMake(originX, originY, size.width, size.height);
        
        UILabel *itemLabel = [self createItemLabelWithTitle:title];
        itemLabel.textColor = self.normalColor;
        itemLabel.font = self.itemFont;
        itemLabel.userInteractionEnabled = true;
        [itemLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapItem:)]];
        [self.itemsView addSubview:itemLabel];
        itemLabel.frame = frame;
        
        UILabel *selectLabel = [self createItemLabelWithTitle:title];
        selectLabel.textColor = self.selectColor;
        selectLabel.font = self.itemFont;
        selectLabel.userInteractionEnabled = false;
        [self.selectItemsView addSubview:selectLabel];
        selectLabel.frame = frame;
    }
    
    UIView *lastItemView = self.itemsView.subviews.lastObject;
    UIView *firstItemView = self.itemsView.subviews.firstObject;
    CGFloat maxX = CGRectGetMaxX(lastItemView.frame) + self.itemSpace;
    self.itemsView.contentSize = CGSizeMake(maxX, 0);
    self.selectItemsView.contentSize = CGSizeMake(maxX, 0);
    
    self.maskView.layer.cornerRadius = lastItemView.bounds.size.height * 0.5;
    self.maskView.layer.masksToBounds = true;
    self.maskView.frame = firstItemView.frame;
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
    
    [UIView animateWithDuration:0.25 animations:^{
        UILabel *toView = [self.selectItemsView.subviews objectAtIndex:toIndex];
        self.maskView.frame = [self getFitItemFrame:toView];
    }];
    [self adjustItemInCenter];
}

// 调整选中的item居中
- (void)adjustItemInCenter {
    
    CGFloat width = [self getSelfWidth];
    NSInteger index = self.selectIndex;
    UIView *selectItemView = [self.itemsView.subviews objectAtIndex:index];
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
    
    if (self.selectBGFitItemWidth) {
        return itemView.frame;
    } else {
        NSInteger index = [self.selectItemsView.subviews indexOfObject:itemView];
        if (index == NSNotFound) {
            return CGRectZero;
        }
        CGSize textSize = [self.itemsSizeList[index] CGSizeValue];
        CGSize fitSize = CGSizeMake(textSize.width + self.itemWrapperWidthSpace , textSize.height + self.itemWrapperHeightSpace);
        CGFloat offsetW = itemView.bounds.size.width - fitSize.width;
        return CGRectMake(itemView.frame.origin.x + offsetW * 0.5, itemView.frame.origin.y, fitSize.width, fitSize.height);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == self.itemsView) {
        self.selectItemsView.contentOffset = scrollView.contentOffset;
    }
}

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

- (void)setSelectBGColor:(UIColor *)selectBGColor {
    _selectBGColor = selectBGColor;
    self.selectItemsView.backgroundColor = selectBGColor;
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
