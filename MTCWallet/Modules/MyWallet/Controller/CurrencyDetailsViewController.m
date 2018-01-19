//
//  CurrencyDetailsViewController.m
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/2.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "CurrencyDetailsViewController.h"
#import "CurrencyDetailsTableViewCell.h"
#import "ZSCustomButton.h"
#import "TransactionDetailsViewController.h"
#import "ReceiveCoinsViewController.h"
#import "SendCoinsViewController.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "Utilities.h"
#import "IndexPathArray.h"
#import "ExportWalletVC.h"
#import "TipVC.h"

#define IMAGE_HEIGHT 240
#define NAVBAR_COLORCHANGE_POINT (IMAGE_HEIGHT - NAVIGATION_BAR_HEIGHT * 2)

#define CONFIRMED_COUNT        12

@interface CurrencyDetailsViewController () <UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (nonatomic, strong) NSMutableArray <TransactionInfo*> *sections;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *currencyLb;
//@property (nonatomic, strong) UILabel *coinCountLb;
@property (nonatomic, strong) UILabel *assetsLb;
@property (nonatomic, strong) ZSCustomButton *receiveBtn;
@property (nonatomic, strong) ZSCustomButton *sendBtn;
@property (nonatomic, strong) UIButton *backupWalletBtn;
@end

@implementation CurrencyDetailsViewController

- (instancetype)initWithWallet:(Wallet*)wallet {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _wallet = wallet;
        
        _accountAddress = [_wallet addressForIndex:_wallet.activeAccountIndex];
        _accountChainId = [_wallet chainIdForIndex:_wallet.activeAccountIndex];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyBalanceDidChange:)
                                                     name:WalletAccountBalanceDidChangeNotification
                                                   object:_wallet];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyBalanceDidChange:)
                                                     name:WalletAccountTokenBalanceDidChangeNotification
                                                   object:_wallet];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(noticeUpdateTransactions)
                                                     name:WalletAccountHistoryUpdatedNotification
                                                   object:_wallet];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(noticeUpdateTransactions)
                                                     name:WalletTransactionDidChangeNotification
                                                   object:_wallet];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configElements];
    [self configData];
    [self reloadTableAnimated:YES];
}

#pragma make - Private Method
- (void)configElements {
    
    [self.view addSubview:self.tableView];
    [self.topView addSubview:self.currencyLb];
//    [self.topView addSubview:self.coinCountLb];
    [self.topView addSubview:self.assetsLb];
    [self.topView addSubview:self.receiveBtn];
    [self.topView addSubview:self.sendBtn];
    [self.topView addSubview:self.backupWalletBtn];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.currencyLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topView);
        make.top.equalTo(self.topView).offset(40);
    }];
    
//    [self.coinCountLb mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.topView);
//        make.top.equalTo(self.currencyLb.mas_bottom).offset(5);
//    }];
    
    [self.assetsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topView);
        make.top.equalTo(self.self.currencyLb.mas_bottom).offset(5);
    }];
    
    [self.backupWalletBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.topView);
        make.height.mas_equalTo(50);
    }];
    
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView);
        make.width.mas_equalTo(ScreenWidth/2);
        make.bottom.equalTo(self.backupWalletBtn.mas_top);
        make.height.mas_equalTo(self.backupWalletBtn.mas_height);
    }];
    
    [self.receiveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sendBtn.mas_right);
        make.bottom.equalTo(self.backupWalletBtn.mas_top);
        make.size.equalTo(self.sendBtn);
    }];

}

- (void)buttonClick:(ZSCustomButton *)sender {
    switch (sender.tag) {
        case 1:
        {
            //跳转到转账界面
            SendCoinsViewController *sendCoinVC = [[SendCoinsViewController alloc] initWithWallet:_wallet];
            [self.navigationController pushViewController:sendCoinVC animated:YES];

            break;
        }
            
        case 2:
        {
            //跳转到收款界面
            ReceiveCoinsViewController *receiveCoinVC = [[ReceiveCoinsViewController alloc] initWithWallet:_wallet];
            [self.navigationController pushViewController:receiveCoinVC animated:YES];
            break;
        }
            
        case 3:
        {
            //备份/导出钱包
            [[TipVC showTipType:ShowTipTypePassword inController:self] setOnCompletion:^(id password, NSInteger index) {
                if (password) {
                    __weak typeof(self) weakSelf = self;
                    [SVProgressHUD showWithStatus:NSLocalizedString(@"密码验证中...", nil)];
                    [_wallet verifyTransactionPassword:password index:_wallet.activeAccountIndex callBack:^(BOOL unlock) {
                        [SVProgressHUD dismiss];
                        if (unlock) {
                            [weakSelf showTipVCWithPassword:password];
                        } else {
                            showMessage(showTypeError, NSLocalizedString(@"交易密码错误", nil));
                        }
                    }];
                }else if(index == 1){
                    showMessage(showTypeError, NSLocalizedString(@"交易密码错误", nil));
                }
            }];

            break;
        }
            
        default:
            break;
    }
}

- (void)showTipVCWithPassword:(NSString *)password {
    //备份/导出钱包
    __weak typeof(self) weakSelf = self;
    [_wallet exportAccountAtIndex:_wallet.activeAccountIndex inController:self password:password callback:^(ExportWalletVC *vc) {
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ==== 余额
- (void)configData {
    NSString *address = [[_wallet addressForIndex:_wallet.activeAccountIndex] checksumAddress];
    NSLog(@"%@",address);
    
    [self setTokenBalance:[_wallet tokenBalanceForIndex:_wallet.activeAccountIndex]];
}

- (void)notifyBalanceDidChange: (NSNotification*)note {
    if ([self checkNote:note]) {
        [self setTokenBalance:[note.userInfo objectForKey:WalletNotificationTokenBalanceKey]];
    }
}

- (void)setTokenBalance:(NSArray<Erc20Token *> *)tokenBalance {
//    if (!balance) { balance = [BigNumber constantZero]; }
    for (Erc20Token *token in tokenBalance) {
        if (token.address == [_wallet activeToken].address || [token.address isEqual:[_wallet activeToken].address]) {
            self.assetsLb.text = [Payment formatEther:token.balance];
            break;
        }
    }
}

- (BOOL)checkNote: (NSNotification*)note {
    Address *address = [note.userInfo objectForKey:WalletNotificationAddressKey];
    Provider *provider = [note.userInfo objectForKey:WalletNotificationProviderKey];
    if (!address || !provider) { return NO; }
    
    return (_wallet.activeAccountProvider.chainId == _accountChainId && [address isEqualToAddress:_accountAddress]);
}

#pragma mark ==== 交易记录
- (void)noticeUpdateTransactions {
    [self reloadTableAnimated:YES];
}

- (void)reloadTableAnimated: (BOOL)animated {
    
    NSArray <TransactionInfo*> *transactions = nil;
    
    // @TODO: Animate by fading
    if (_wallet.activeAccountIndex != AccountNotFound) {
        transactions = [_wallet transactionHistoryForIndex:_wallet.activeAccountIndex];

        self.sections = [NSMutableArray array];
        Address *contractAddress = [_wallet activeToken].address;
        if (contractAddress) {
            //代币合约
            for (TransactionInfo *info in transactions) {
                if ([info.toAddress isEqualToAddress:contractAddress]||[info.contractAddress isEqualToAddress:contractAddress]) {
                    [self.sections addObject:info];
                }
            }
        } else {
            //以太交易记录
            for (TransactionInfo *info in transactions) {
                if (info.contractAddress == nil) {
                    [self.sections addObject:info];
                }
            }
        }
        
        [self.tableView reloadData];
    }
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
        self.title = [NSString stringWithFormat:@"%@ %@",_wallet.activeToken.symbol,NSLocalizedString(@"余额",nil)];
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
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    return 1;
}

#pragma mark - TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 30;
    }
    return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        UIView *headerView = [[UIView alloc] init];
        headerView.backgroundColor = [UIColor commonBackgroundColor];
        
        UILabel *promptLb = [UILabel new];
        promptLb.text = NSLocalizedString(@"交易记录",nil);
        promptLb.font = [UIFont systemFontOfSize:15.0f];
        promptLb.textColor = [UIColor whiteColor];
        [headerView addSubview:promptLb];
        [promptLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(headerView).offset(10);
            make.centerY.equalTo(headerView);
        }];
        return headerView;
    }
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor commonBackgroundColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CurrencyDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CurrencyDetailsTableViewCell at_identifier]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    TransactionInfo *transactionInfo = [_sections objectAtIndex:indexPath.section];
    [cell setAddress:_wallet.activeAccountAddress blockNumber:_wallet.activeAccountBlockNumber transactionInfo:transactionInfo];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TransactionDetailsViewController *recordVC = [[TransactionDetailsViewController alloc] init];
    TransactionInfo *transactionInfo = [_sections objectAtIndex:indexPath.section];
    [recordVC setAddress:_wallet.activeAccountAddress blockNumber:_wallet.activeAccountBlockNumber transactionInfo:transactionInfo];
    [self.navigationController pushViewController:recordVC animated:YES];
}

#pragma mark - Init
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setBackgroundColor:[UIColor commonBackgroundColor]];
        [_tableView registerClass:[CurrencyDetailsTableViewCell class] forCellReuseIdentifier:[CurrencyDetailsTableViewCell at_identifier]];
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

- (UILabel *)currencyLb {
    if (!_currencyLb) {
        _currencyLb = [UILabel new];
        _currencyLb.font = [UIFont systemFontOfSize:18.0f];
        _currencyLb.textColor = [UIColor commonWhiteColor];
        _currencyLb.text = [NSString stringWithFormat:@"%@ %@",_wallet.activeToken.symbol,NSLocalizedString(@"余额",nil)];
    }
    return _currencyLb;
}

//- (UILabel *)coinCountLb {
//    if (!_coinCountLb) {
//        _coinCountLb = [UILabel new];
//        _coinCountLb.font = [UIFont systemFontOfSize:28.0f];
//        _coinCountLb.textColor = [UIColor commonWhiteColor];
//        _coinCountLb.text = @"0.0";
//    }
//    return _coinCountLb;
//}

- (UILabel *)assetsLb {
    if (!_assetsLb) {
        _assetsLb = [UILabel new];
        _assetsLb.font = [UIFont systemFontOfSize:15.0f];
        _assetsLb.textColor = [UIColor commonWhiteColor];
        _assetsLb.text = [Payment formatEther:_wallet.activeToken.balance];
    }
    return _assetsLb;
}

- (ZSCustomButton *)receiveBtn {
    if (!_receiveBtn) {
        _receiveBtn = [[ZSCustomButton alloc] init];
        _receiveBtn.zs_buttonType = ZSCustomButtonImageLeft;
        [_receiveBtn setImage:[UIImage imageNamed:@"receive"] forState:UIControlStateNormal];
        [_receiveBtn setTitle:NSLocalizedString(@"收款",nil) forState:UIControlStateNormal];
        [_receiveBtn setBackgroundColor:[UIColor commonCellcolor]];
        [_receiveBtn setTag:0x02];
        [_receiveBtn addTarget:self action:@selector(buttonClick:)];
    }
    return _receiveBtn;
}

- (ZSCustomButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [[ZSCustomButton alloc] init];
        _sendBtn.zs_buttonType = ZSCustomButtonImageLeft;
        [_sendBtn setImage:[UIImage imageNamed:@"send"] forState:UIControlStateNormal];
        [_sendBtn setTitle:NSLocalizedString(@"转账",nil) forState:UIControlStateNormal];
        [_sendBtn setBackgroundColor:[UIColor commonCellcolor]];
        [_sendBtn setTag:0x01];
        [_sendBtn addTarget:self action:@selector(buttonClick:)];
        [_sendBtn setShowLineType:ShowLineType_Right];
    }
    return _sendBtn;
}

- (UIButton *)backupWalletBtn {
    if (!_backupWalletBtn) {
        _backupWalletBtn = [UIButton new];
        [_backupWalletBtn setTitle:NSLocalizedString(@"备份/导出钱包",nil)];
        [_backupWalletBtn setBackgroundColor:[UIColor commonCellcolor]];
        [_backupWalletBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [_backupWalletBtn setTag:0x03];
        [_backupWalletBtn addTarget:self action:@selector(buttonClick:)];
        [_backupWalletBtn setShowLineType:ShowLineType_Top];
    }
    return _backupWalletBtn;
}

#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    if (!_sections || _sections.count == 0) {
        return YES;
    }
    return NO;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"暂无交易记录", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"666666"]}];
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView{
    return NO;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView{
    return 38;
}
@end
