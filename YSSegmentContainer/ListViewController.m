//
//  ListViewController.m
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/6/28.
//  Copyright © 2019年 all. All rights reserved.
//

#import "ListViewController.h"

@interface ImageTableViewCell : UITableViewCell<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *imgNameList;

@end

@implementation ImageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self customView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.contentView.bounds.size;
    self.collectionView.frame = CGRectMake(0.0, 0.0, size.width, size.height);
}

- (void)customView {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 20.0;
    flowLayout.minimumLineSpacing = 20.0;
    flowLayout.sectionInset = UIEdgeInsetsMake(10.0, 20.0, 10.0, 20.0);
    flowLayout.itemSize = CGSizeMake(70.0, 70.0);
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = false;
    self.collectionView.showsVerticalScrollIndicator = false;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.contentView addSubview:self.collectionView];
}

- (void)setImgNameList:(NSArray *)imgNameList {
    _imgNameList = imgNameList;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imgNameList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UIImageView *imgView = [cell.contentView viewWithTag:101];
    if (!imgView) {
        imgView = [[UIImageView alloc] init];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.tag = 101;
        imgView.clipsToBounds = true;
        [cell.contentView addSubview:imgView];
        imgView.frame = cell.contentView.bounds;
    }
    imgView.image = [UIImage imageNamed:self.imgNameList[indexPath.row]];
    return cell;
}

@end

#pragma mark ##### TextTableViewCell

@interface TextTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation TextTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self customView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.titleLabel sizeToFit];
    [self.contentLabel sizeToFit];
    CGFloat width = self.contentView.bounds.size.width;
    self.titleLabel.frame = CGRectMake(16.0, 10.0, width - 32.0, self.titleLabel.bounds.size.height);
    self.contentLabel.frame = CGRectMake(16.0, CGRectGetMaxY(self.titleLabel.frame) + 10.0, width - 32.0, self.contentLabel.bounds.size.height);
}

- (void)customView {
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.font = [UIFont systemFontOfSize:15.0];
    self.titleLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.titleLabel];

    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.contentLabel.font = [UIFont systemFontOfSize:12.0];
    self.contentLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    [self.contentView addSubview:self.contentLabel];
}

@end

#pragma mark ##### ListViewController

#define kTitleKey  @"kTitleKey"
#define kContentKey  @"kContentKey"
#define kTypeKey  @"kTypeKey"

@interface ListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataList;

@end

@implementation ListViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self customView];
    [self createSimulatData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.frame = CGRectMake(0.0, self.view.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.height);
    } else {
        self.tableView.frame = CGRectMake(0.0, self.view.layoutMargins.top, self.view.bounds.size.width, self.view.bounds.size.height);
    }
}
#pragma mark - public
#pragma mark - incident
#pragma mark - private
- (void)customView {
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = false;
    }
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.tableView registerClass:[TextTableViewCell class] forCellReuseIdentifier:@"textCell"];
    [self.tableView registerClass:[ImageTableViewCell class] forCellReuseIdentifier:@"imgCell"];
    [self.view addSubview:self.tableView];
}

- (void)createSimulatData {
    
    NSString *sectionTitle = self.title;
    NSInteger random = arc4random_uniform(10);
    NSMutableArray *list = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        if (random == i) {
            NSMutableArray *imgList = [NSMutableArray array];
            for (int i = 1; i < 10; i++) {
                int index = i % 3;
                NSString *imgName = [NSString stringWithFormat:@"%03d", index + 1];
                [imgList addObject:imgName];
            }
            NSDictionary *info = @{kContentKey: imgList, kTypeKey: @"2"};
            [list addObject:info];
        } else {
            NSString *title = [NSString stringWithFormat:@"这条内容是: %@%d", sectionTitle, i];
            NSString *content = [NSString stringWithFormat:@"这详细内容为..."];
            NSString *type = @"1";
            NSDictionary *info = @{kTitleKey: title, kContentKey: content, kTypeKey: type};
            [list addObject:info];
        }
    }
    self.dataList = [list copy];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *info = self.dataList[indexPath.row];
    NSString *type = [info objectForKey:kTypeKey];
    UITableViewCell *cell = nil;
    if ([type isEqualToString:@"1"]) {
        TextTableViewCell *textCell = [tableView dequeueReusableCellWithIdentifier:@"textCell"];
        textCell.titleLabel.text = [info objectForKey:kTitleKey];
        textCell.contentLabel.text = [info objectForKey:kContentKey];
        cell = textCell;
    } else if ([type isEqualToString:@"2"]) {
        ImageTableViewCell *imgCell = [tableView dequeueReusableCellWithIdentifier:@"imgCell"];
        NSArray *imgList = [info objectForKey:kContentKey];
        imgCell.imgNameList = imgList;
        cell = imgCell;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *info = self.dataList[indexPath.row];
    NSString *type = [info objectForKey:kTypeKey];
    if ([type isEqualToString:@"1"]) {
        return 63.0;
    } else if ([type isEqualToString:@"2"]) {
        return 100.0;
    } else {
        return 44.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}



#pragma mark - getter/setter
@end
