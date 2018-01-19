//
//  AddNewAssetsViewController.m
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/4.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "AddNewAssetsViewController.h"
#import "AddNewAssetsTableViewCell.h"

@interface AddNewAssetsViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<Erc20Token *> *currencyArray;

@end

@implementation AddNewAssetsViewController


- (instancetype)initWithWallet:(Wallet*)wallet {
    self = [super init];
    self.currencyArray = [wallet tokenBalanceForIndex:wallet.activeAccountIndex];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"添加新资产",nil);
    [self.view setBackgroundColor:[UIColor commonBackgroundColor]];
    [self configElements];
}


#pragma make - Private Method
- (void)configElements {
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.currencyArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    return 1;
}

#pragma mark - TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [UIView new];
    headerView.backgroundColor = [UIColor commonBackgroundColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddNewAssetsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddNewAssetsTableViewCell at_identifier]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    Erc20Token *token = self.currencyArray[indexPath.section];
    cell.currencyLb.text = token.symbol;
    [cell.coinImg sd_setImageWithURL:[NSURL URLWithString:token.image] placeholderImage:[UIImage imageNamed:@""]];
    [cell.showSwitch setOn:token.balance == [BigNumber constantZero]];
    
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
        [_tableView registerClass:[AddNewAssetsTableViewCell class] forCellReuseIdentifier:[AddNewAssetsTableViewCell at_identifier]];
    }
    return _tableView;
}

@end
