//
//  MainStartHomeViewController.m
//  ZSEthersWallet
//
//  Created by thomasho on 2017/12/28.
//  Copyright © 2017年 lkl. All rights reserved.
//

#import "MainStartHomeViewController.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "MainStartHomeTableViewCell.h"

#import "AccountsViewController.h"
#import "ReceiveCoinsViewController.h"
#import "SendCoinsViewController.h"
#import "CurrencyDetailsViewController.h"
#import "AddNewAssetsViewController.h"
#import "ZSCustomButton.h"
#import "WalletManagerView.h"

#import "Utilities.h"
#import "CachedDataStore.h"

#import <ethers/Erc20Token.h>

#define IMAGE_HEIGHT 80
#define NAVBAR_COLORCHANGE_POINT (IMAGE_HEIGHT - NAVIGATION_BAR_HEIGHT * 2)

@interface MainStartHomeViewController () <UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate,AccountsViewControllerDelegate,CAAnimationDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *assetsLb;
@property (nonatomic, strong) UILabel *totalLb;
//@property (nonatomic, strong) UIView *colorView;
@property (nonatomic, strong) NSArray<Erc20Token *> *currencyArray;
@end

@implementation MainStartHomeViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor commonBackgroundColor]];
    
    [self configElements];
    
    _wallet = [Wallet walletWithKeychainKey:@"sharedWallet"];
    
    self.currencyArray = [_wallet tokenBalanceForIndex:_wallet.activeAccountIndex];
    if (_currencyArray.count == 0) {
        self.currencyArray = @[[Erc20Token tokenFromDictionary:@{@"symbol":@"ETH",@"balance":[BigNumber constantZero]}] , [Erc20Token tokenFromDictionary:@{@"symbol":@"MTC",@"balance":[BigNumber constantZero]}]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBalance)
                                                 name:WalletAccountBalanceDidChangeNotification
                                               object:_wallet];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBalance)
                                                 name:WalletAccountTokenBalanceDidChangeNotification
                                               object:_wallet];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noticeUpdateActiveAccount)
                                                 name:WalletActiveAccountDidChangeNotification
                                               object:_wallet];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noticeUpdateActiveAccount)
                                                 name:WalletAccountNicknameDidChangeNotification
                                               object:_wallet];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([_wallet numberOfAccounts]) {
        self.title = [_wallet nicknameForIndex:_wallet.activeAccountIndex];
        _accountAddress = [_wallet addressForIndex:_wallet.activeAccountIndex];
        _accountChainId = [_wallet chainIdForIndex:_wallet.activeAccountIndex];
        //[self setBalance:[_wallet balanceForIndex:_wallet.activeAccountIndex]];
    }
}
#pragma mark - **************** Notify

- (void)updateBalance {
    if (_wallet.activeAccountIndex != AccountNotFound) {
        _assetsLb.text = [_wallet assetsForIndex:_wallet.activeAccountIndex];
        NSArray *arr = [_wallet tokenBalanceForIndex:_wallet.activeAccountIndex];
        if (arr.count) {
            self.currencyArray = arr;
        }
    } else {
        _assetsLb.text = @"-";
    }
    CachedDataStore *dataStore = [CachedDataStore sharedCachedDataStoreWithKey:CACHEKEY_APP_DATA];
    NSString *unit = [dataStore stringForKey:CACHEKEY_APP_DATA_UNIT];
    _totalLb.text = [NSString stringWithFormat:@"%@（%@）",NSLocalizedString(@"总资产",nil),[unit isEqualToString:UNIT_DOLLAR]?UNIT_DOLLAR_NAME:UNIT_RMB_NAME];
    [self reloadTableAnimated:YES];
}

- (void)noticeUpdateActiveAccount {
    [self updatedActiveAccountAnimated:YES];
}

- (void)updatedActiveAccountAnimated: (BOOL)animated {
    
    [self updateBalance];
}

#pragma mark - UITableViewDataSoruce and UITableViewDelegate

- (void)reloadTableAnimated: (BOOL)animated {
    [self.tableView reloadData];
}

#pragma mark - Private Method
- (void)configElements {
    self.title = NSLocalizedString(@"我的钱包", nil);
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImageNamed:@"set" targe:self action:@selector(rightBarButtonItemClick)];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.tableView setTableHeaderView:self.topView];
    [self.topView addSubview:self.assetsLb];
    [self.topView addSubview:self.totalLb];
//    [self.topView addSubview:self.colorView];
    
    [self.assetsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topView);
        make.top.equalTo(self.topView);
    }];
    
    [self.totalLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topView);
        make.bottom.equalTo(self.topView).offset(-22);
    }];
    
//    [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.bottom.equalTo(self.topView);
//        make.height.mas_equalTo(@10);
//    }];
}

- (void)rightBarButtonItemClick {
    [AccountsViewController showInController:self wallet:_wallet];
}

#pragma mark ==== 余额
/*- (void)notifyBalanceDidChange: (NSNotification*)note {
    if ([self checkNote:note]) {
        [self setBalance:[note.userInfo objectForKey:WalletNotificationBalanceKey]];
    }
}

- (void)setBalance:(BigNumber *)balance {
    if (!balance) { balance = [BigNumber constantZero]; }
    
    NSString *string = [Payment formatEther:balance
                                    options:(EtherFormatOptionCommify | EtherFormatOptionApproximate)];
    
    self.assetsLb.text = string;
}

- (BOOL)checkNote: (NSNotification*)note {
    Address *address = [note.userInfo objectForKey:WalletNotificationAddressKey];
    Provider *provider = [note.userInfo objectForKey:WalletNotificationProviderKey];
    if (!address || !provider) { return NO; }
    
    return (_wallet.activeAccountProvider.chainId == _accountChainId && [address isEqualToAddress:_accountAddress]);
}*/

#pragma mark - Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY > NAVBAR_COLORCHANGE_POINT)
    {
        [self wr_setStatusBarStyle:UIStatusBarStyleDefault];
    } else {
        [self wr_setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.currencyArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (section)?3:11;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] init];
    if (section) {
        headerView.backgroundColor = [UIColor mainThemeColor];
    }else {
        headerView.backgroundColor = [UIColor mainThemeColor];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 8)];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        view.backgroundColor = [UIColor commonGreenColor];
        [headerView addSubview:view];
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //添加新资产
//    if (indexPath.section == self.currencyArray.count) {
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell at_identifier]];
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        ZSCustomButton *addBtn = [ZSCustomButton new];
//        addBtn.zs_buttonType = ZSCustomButtonImageLeft;
//        [addBtn setTitle:NSLocalizedString(@"添加新资产",nil)];
//        [addBtn setTitleColor:[UIColor commonWhiteColor]];
//        [addBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
//        [addBtn setBackgroundColor:[UIColor commonCellcolor]];
//        [cell.contentView addSubview:addBtn];
//        [addBtn setUserInteractionEnabled:NO];
//        [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(cell.contentView);
//        }];
//        return cell;
//    }
//    else {
        MainStartHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MainStartHomeTableViewCell at_identifier]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.delegate = self;
    [cell setMainStartHomeTableViewCellInfo:self.currencyArray[indexPath.section] defaultPrice:_wallet.etherPrice];
        return cell;
//    }
//    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if (indexPath.section == self.currencyArray.count) {
//        //添加新资产
//        AddNewAssetsViewController *newAssetsVC = [[AddNewAssetsViewController alloc] initWithWallet:_wallet];
//        [self.navigationController pushViewController:newAssetsVC animated:YES];
//    }
//    else {
        //跳转到币种详情界面
        [_wallet setActiveToken:self.currencyArray[indexPath.section]];
        CurrencyDetailsViewController *detailVC = [[CurrencyDetailsViewController alloc] initWithWallet:_wallet];
        [self.navigationController pushViewController:detailVC animated:YES];
//    }
}

#pragma mark - MGSwipeTableCellDelegate
-(NSArray *)swipeTableCell:(MGSwipeTableCell *)cell
  swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings *)swipeSettings
         expansionSettings:(MGSwipeExpansionSettings *) expansionSettings
{
    swipeSettings.transition = MGSwipeTransitionBorder;
    expansionSettings.buttonIndex = 0;
    
    if (direction == MGSwipeDirectionLeftToRight) {
        expansionSettings.fillOnTrigger = NO;
        expansionSettings.threshold = 1;
        
        return @[[MGSwipeButton buttonWithTitle:NSLocalizedString(@"  收款", nil) icon:[UIImage imageNamed:@"receive"] backgroundColor:[UIColor commonGreenColor] callback:^BOOL(MGSwipeTableCell * sender){
            //从右往左滑动，跳转到收币界面
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            [_wallet setActiveToken:self.currencyArray[indexPath.section]];
            ReceiveCoinsViewController *receiveCoinVC = [[ReceiveCoinsViewController alloc] initWithWallet:_wallet];
            [self.navigationController.view setAnimationWithType:AnimationType_MoveIn duration:0.1 directionSubtype:Direction_Left];
            [self.navigationController pushViewController:receiveCoinVC animated:NO];
            return YES;
        }]];
    }
    else {
        expansionSettings.fillOnTrigger = NO;
        expansionSettings.threshold = 1;

        return @[ [MGSwipeButton buttonWithTitle:NSLocalizedString(@"  转账", nil) icon:[UIImage imageNamed:@"send"]  backgroundColor:[UIColor commonOrangeTextColor] callback:^BOOL(MGSwipeTableCell * sender){
            //从左往右滑动，跳转到发送币界面
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            [_wallet setActiveToken:self.currencyArray[indexPath.section]];
            SendCoinsViewController *sendCoinVC = [[SendCoinsViewController alloc] initWithWallet:_wallet];
            self.navigationController.view.backgroundColor = [UIColor blackColor];
//            [self.navigationController.view setAnimationWithType:AnimationType_MoveIn duration:10.1f directionSubtype:Direction_Right];
            [self.navigationController pushViewController:sendCoinVC animated:YES];
            return YES;
        }]];
    }
}

#pragma mark - AccountsViewControllerDelegate

- (void)accountsViewControllerDidCancel:(AccountsViewController *)accountsViewController {
//    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)accountsViewController:(AccountsViewController *)accountsViewController didSelectAccountIndex:(NSInteger)accountIndex {
    _wallet.activeAccountIndex = accountIndex;
    self.title = [_wallet nicknameForIndex:accountIndex];
}

//是否修改了当前钱包名称
- (void)accountsViewController: (AccountsViewController*)accountsViewController changedNickname: (NSInteger)accountIndex {
    if (_wallet.activeAccountIndex == accountIndex) {
        self.title = [_wallet nicknameForIndex:accountIndex];
    }
}

- (void)accountsViewController: (AccountsViewController*)accountsViewController removeAccountIndex: (NSInteger)accountIndex {
    self.title = @"Wallet";
    if (accountIndex == _wallet.activeAccountIndex && _wallet.numberOfAccounts > 1) {
        _wallet.activeAccountIndex = 0;
        self.title = [_wallet nicknameForIndex:0];
    }
}

#pragma mark - Init
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setBackgroundColor:[UIColor mainThemeColor]];
        [_tableView registerClass:[MainStartHomeTableViewCell class] forCellReuseIdentifier:[MainStartHomeTableViewCell at_identifier]];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:[UITableViewCell at_identifier]];
    }
    return _tableView;
}

- (UIView *)topView {
    if (!_topView ) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, IMAGE_HEIGHT)];
        _topView.backgroundColor = [UIColor mainThemeColor];
    }
    return _topView;
}

- (UILabel *)assetsLb {
    if (!_assetsLb) {
        _assetsLb = [UILabel new];
        _assetsLb.font = [UIFont systemFontOfSize:25.0f];
        _assetsLb.textColor = [UIColor commonOrangeTextColor];
    }
    return _assetsLb;
}

- (UILabel *)totalLb {
    if (!_totalLb) {
        _totalLb = [UILabel new];
        _totalLb.font = [UIFont systemFontOfSize:16.0f];
        _totalLb.textColor = [UIColor commonWhiteColor];
    }
    return _totalLb;
}

//- (UIView *)colorView {
//    if (!_colorView) {
//        _colorView = [UIView new];
//        _colorView.backgroundColor = [UIColor commonGreenColor];
//    }
//    return _colorView;
//}

@end
