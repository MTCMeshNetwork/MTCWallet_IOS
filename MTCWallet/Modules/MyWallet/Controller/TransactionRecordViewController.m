//
//  TransactionRecordViewController.m
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/2.
//  Copyright © 2018年 lkl. All rights reserved.
//  交易记录

#import "TransactionRecordViewController.h"
#import "ZSCustomButton.h"

#define IMAGE_HEIGHT 180
#define NAVBAR_COLORCHANGE_POINT (IMAGE_HEIGHT - NAVIGATION_BAR_HEIGHT * 2)

@interface TransactionRecordViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *titleLb;
@property (nonatomic, strong) UILabel *coinCountLb;
@property (nonatomic, strong) UILabel *assetsLb;
@property (nonatomic, strong) ZSCustomButton *doneView;
@end

@implementation TransactionRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor commonBackgroundColor]];
    
    [self configElements];
}


#pragma make - Private Method
- (void)configElements {
    [self.view addSubview:self.tableView];
    [self.topView addSubview:self.titleLb];
    [self.topView addSubview:self.coinCountLb];
    [self.topView addSubview:self.assetsLb];
    [self.topView addSubview:self.doneView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topView);
        make.top.equalTo(self.topView).offset(40);
    }];
    
    [self.coinCountLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topView);
        make.top.equalTo(self.titleLb.mas_bottom).offset(5);
    }];
    
    [self.assetsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topView);
        make.top.equalTo(self.coinCountLb.mas_bottom).offset(5);
    }];
    
    [self.doneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.topView);
        make.height.mas_equalTo(35);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY > NAVBAR_COLORCHANGE_POINT)
    {
        CGFloat alpha = (offsetY - NAVBAR_COLORCHANGE_POINT) / NAVIGATION_BAR_HEIGHT;
        [self wr_setNavBarBackgroundAlpha:alpha];
        [self wr_setNavBarTintColor:[[UIColor blackColor] colorWithAlphaComponent:alpha]];
        [self wr_setNavBarTitleColor:[[UIColor commonWhiteColor] colorWithAlphaComponent:alpha]];
        [self wr_setStatusBarStyle:UIStatusBarStyleDefault];
        self.title = @"Transaction Record";
    }
    else
    {
        [self wr_setNavBarBackgroundAlpha:0];
        [self wr_setNavBarTintColor:[UIColor whiteColor]];
        [self wr_setNavBarTitleColor:[UIColor commonWhiteColor]];
        [self wr_setStatusBarStyle:UIStatusBarStyleLightContent];
        self.title = @"";
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TransactionRecordMaxSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    return 1;
}

#pragma mark - TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case TransactionRecordSection_Recive:
        case TransactionRecordSection_Send:
            return 15;
            break;
            
        default:
            break;
    }
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UIView *headerView = [[UIView alloc] init];
    
    UILabel *promptLb = [UILabel new];
    promptLb.font = [UIFont systemFontOfSize:12.0f];
    promptLb.textColor = [UIColor whiteColor];
    [headerView addSubview:promptLb];
    [promptLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).offset(10);
        make.centerY.equalTo(headerView);
    }];
    
    if (section == TransactionRecordSection_Send) {
        headerView.backgroundColor = [UIColor commonGreenColor];
        promptLb.text = @"Send ID";
        return headerView;
    }
    else if (section == TransactionRecordSection_Recive) {
        headerView.backgroundColor = [UIColor commonPinkColor];
        promptLb.text = @"Receive ID";
        return headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell at_identifier]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.textLabel.text = @"0x9d7eeb2bf9439bc176184ec2e43d74caed3b7e6";
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    cell.backgroundColor = [UIColor commonCellcolor];
    return cell;
}

#pragma mark - Init
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setBackgroundColor:[UIColor commonBackgroundColor]];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:[UITableViewCell at_identifier]];
        _tableView.contentInset = UIEdgeInsetsMake(-NAVIGATION_BAR_HEIGHT, 0, 0, 0);
        _tableView.tableHeaderView = self.topView;
    }
    return _tableView;
}

- (UIView *)topView {
    if (!_topView ) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, IMAGE_HEIGHT)];
        _topView.backgroundColor = [UIColor commonBackgroundColor];
    }
    return _topView;
}

- (UILabel *)titleLb {
    if (!_titleLb) {
        _titleLb = [UILabel new];
        _titleLb.font = [UIFont systemFontOfSize:18.0f];
        _titleLb.textColor = [UIColor commonWhiteColor];
        _titleLb.text = @"Transaction Record";
    }
    return _titleLb;
}

- (UILabel *)coinCountLb {
    if (!_coinCountLb) {
        _coinCountLb = [UILabel new];
        _coinCountLb.font = [UIFont systemFontOfSize:28.0f];
        _coinCountLb.textColor = [UIColor whiteColor];

        [_coinCountLb setAttributedText:[NSAttributedString getAttributWithString:@"0.0 ETH" UnChangePart:@"0.0 " changePart:@"ETH" changeColor:[UIColor whiteColor] changeFont:[UIFont systemFontOfSize:13.0f]]];
    }
    return _coinCountLb;
}

- (UILabel *)assetsLb {
    if (!_assetsLb) {
        _assetsLb = [UILabel new];
        _assetsLb.font = [UIFont systemFontOfSize:15.0f];
        _assetsLb.textColor = [UIColor commonWhiteColor];
        _assetsLb.text = NSLocalizedString(@"交易市值 ￥0.0",nil);
    }
    return _assetsLb;
}

- (ZSCustomButton *)doneView {
    if (!_doneView) {
        _doneView = [[ZSCustomButton alloc] init];
        _doneView.zs_buttonType = ZSCustomButtonImageLeft;
        [_doneView setImage:[UIImage imageNamed:@"success"] forState:UIControlStateNormal];
        [_doneView setTitle:@"Done" forState:UIControlStateNormal];
        [_doneView setBackgroundColor:[UIColor commonRedColor]];
    }
    return _doneView;
}
@end
