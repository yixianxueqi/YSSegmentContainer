
[![Build Status](https://travis-ci.org/yixianxueqi/YSSegmentContainer.svg?branch=master)](https://travis-ci.org/yixianxueqi/YSSegmentContainer) [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/YSSegmentContainer.svg)](https://img.shields.io/cocoapods/v/YSSegmentContainer.svg)

# YSSegmentContainer
It's a container, appearance looks like news app Layout. Simple And Convenience！

## Appearance

<img src="./resource/gif/record_opt.gif" width="320" style="display: inline-block;float: center;"> 


## Usage

* First create container

```
self.segmentContainerVC = [[YSSegmentContainerViewController alloc] init];
// optional
self.segmentContainerVC.incidentDelegate = self;
```

* deploy TabView, and set subViewControllers. 
Two TabView are provided: YSMenuItemWrapperView and YSMenuItemSliderView. If It's not satisfy you, you can implement youself TabView by create YSMenuItemView's subclass.

```
YSMenuItemWrapperView *menuView = [[YSMenuItemWrapperView alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, 44.0)];
menuView.itemWrapperWidthSpace = 30.0;
self.segmentContainerVC.menuView = menuView;

NSArray *titleList = @[@"推荐", @"热门", @"体育", @"财经", @"社会", @"科技", @"幽默", @"军事", @"服装", @"教育"];
NSMutableArray *vcList = [NSMutableArray array];
for (int i = 0; i < titleList.count; i++) {
    NSString *title = titleList[i];
    ListViewController *tempVC = [[ListViewController alloc] init];
    tempVC.title = title;
    [vcList addObject:tempVC];
}
self.segmentContainerVC.viewControllers = [vcList copy];
    
```

* add to parentViewController to show

```
    [self addChildViewController:self.segmentContainerVC];
    [self.segmentContainerVC didMoveToParentViewController:self];
    [self.view addSubview:self.segmentContainerVC.view];
```

* deploy which one to show, default 0

```
[self.segmentContainerVC setShowIndex:1];
```

-----
> more detail see "DemoViewController"

## Install

##### cocopods

```
 pod search YSSegmentContainer
```

If you can't search the result of it, you can update your pods index by
```
pod repo update
```
or clear your local pods index by
```
rm ~/Library/Caches/CocoaPods/search_index.json
```
Then, search again.


After, add it to your Podfile, 
```
pod 'YSSegmentContainer', '~>1.1.2'
```

Finall, run commend

```
pod install
```

##### source code

In directory "YSSegmentContainer"

```
YSSegmentContainerViewController.h
YSSegmentContainerViewController.m
YSMenuItemView.h
YSMenuItemView.m
YSMenuItemWrapperView.h
YSMenuItemWrapperView.m
YSMenuItemSliderView.h
YSMenuItemSliderView.m
```


