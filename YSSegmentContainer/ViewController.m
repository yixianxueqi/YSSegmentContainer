//
//  ViewController.m
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/27.
//  Copyright © 2019年 all. All rights reserved.
//

#import "ViewController.h"
#import "DemoViewController.h"

@interface ViewController ()

@property (nonatomic, weak) UIButton *pushBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"YSSegmengContainer";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self customView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.pushBtn.bounds = CGRectMake(0.0, 0.0, 100.0, 40.0);
    self.pushBtn.center = self.view.center;
}

- (void)customView {
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
    [btn setTitle:@"push Demo" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(pushDemo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    self.pushBtn = btn;
}

- (void)pushDemo {
 
    DemoViewController *demo = [[DemoViewController alloc] init];
    [self.navigationController pushViewController:demo animated:true];
}


@end
