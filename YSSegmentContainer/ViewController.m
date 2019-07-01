//
//  ViewController.m
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/27.
//  Copyright © 2019年 all. All rights reserved.
//

#import "ViewController.h"
#import "DemoViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UIButton *pushBtn;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *list;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"YSSegmengContainer";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self prepareData];
    [self customView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [super viewDidLayoutSubviews];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.frame = CGRectMake(0.0, self.view.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom);
    } else {
        self.tableView.frame = CGRectMake(0.0, self.view.layoutMargins.top, self.view.bounds.size.width, self.view.bounds.size.height - self.view.layoutMargins.top - self.view.layoutMargins.bottom);
    }
}

- (void)prepareData {
    
    self.list = @[@"wrapper", @"equal wrapper", @"slider", @"equal slider"];
}

- (void)customView {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = false;
    }
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.list[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    DemoViewController *demoVC = [[DemoViewController alloc] init];
    demoVC.type = self.list[indexPath.row];
    [self.navigationController pushViewController:demoVC animated:true];
}

@end
