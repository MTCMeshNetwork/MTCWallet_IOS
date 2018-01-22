//
//  SendCoinsViewController.m
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/2.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "SendCoinsViewController.h"
#import "TransferAccountsTableViewCell.h"
#import "ScanQRCodeViewController.h"
#import "ScannerConfigController.h"
#import "Utilities.h"
#import <ethers/Address.h>
#import "ModalViewController.h"
#import "ZSBaseNavigationViewController.h"
#import "ethers/SecureData.h"

typedef NS_ENUM(NSInteger, TransferAccountsType) {
    TransferAccountsType_AddressSection,   //接收地址
    TransferAccountsType_CountSection,     //转账数量
    TransferAccountsType_AwardSection,     //矿工奖励
    TransferAccountsType_RemarkSection,    //交易备注
    TransferAccountsType_GasPriceSection,  //Gas Price
    TransferAccountsType_GasSection,       //Gas
    TransferAccountsType_NetworkSection,   //network
    TransferAccountsType_TotalCostSection, //总计耗费
    TransferAccountsType_PasWordSection,   //钱包密码
    TransferAccountsType_ConfirmSection,   //确认转账
    TransferAccountsTypeMaxSection,
};
@interface SendCoinsViewController () <UITableViewDelegate,UITableViewDataSource>
{
    UILabel *_etherPriceLabel;
    ArrayPromise *_addressInspectionPromise;
    BigNumber *_fuzzyEstimate;
    BigNumber *_gasPriceEstimate;
}
@property (nonatomic, assign) BOOL isAdvanceOn;
@property (nonatomic, copy) NSString *address, *count, *remark, *gasPrice, *gasLimit, *password;

@property (nonatomic, assign) float awardValue;
@property (nonatomic, readonly) Transaction *transaction;

@property (nonatomic, assign) BOOL feeReady;
@property (nonatomic, strong) BigNumber *gasEstimate;

@end

@implementation SendCoinsViewController

//- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

- (instancetype)initWithWallet:(Wallet*)wallet {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _wallet = wallet;
        
//        [_wallet scan:^(Hash *hash, NSError *error) {
//            NSLog(@"WalletViewController: Scanned Transaction - hash=%@ error=%@", hash, error);
//        }];
        
        _signer = [_wallet signer];
        [_signer lock];
        
        
        [[_signer.provider getGasPrice] onCompletion:^(BigNumberPromise *promise) {
            if (promise.error) {
                return ;
            }
            _gasPriceEstimate = promise.value;
            self.gasPrice = [_gasPriceEstimate div:[BigNumber bigNumberWithDecimalString:@"1000000000"]].decimalString;
            [self updateTotalCostData];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:TransferAccountsType_AwardSection] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
        
                       
        NSString *fromAddressString = [[_wallet addressForIndex:_wallet.activeAccountIndex] checksumAddress];
        Transaction *transaction = [Transaction transactionWithFromAddress:[Address addressWithString:fromAddressString]];
        _transaction = transaction;
        _transaction.chainId = _signer.provider.chainId;
        _transaction.nonce = _signer.transactionCount;
        //默认20Gwei，21000gas
//        _transaction.gasPrice = [BigNumber bigNumberWithDecimalString:@"20000000000"];
//        _transaction.gasLimit = [BigNumber bigNumberWithDecimalString:@"21000"];
        self.gasPrice = @"20";
        self.gasLimit = [_wallet activeToken].address?@"60000":@"25200";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [[_wallet activeToken].symbol stringByAppendingString:NSLocalizedString(@"  转账",nil)];
    [self.view setBackgroundColor:[UIColor commonBackgroundColor]];
    // 设置导航栏颜色
    [self wr_setNavBarBarTintColor:[UIColor commonBackgroundColor]];
    // 设置初始导航栏透明度
    [self wr_setNavBarBackgroundAlpha:1];
    [self wr_setNavBarTitleColor:[[UIColor commonWhiteColor] colorWithAlphaComponent:1]];
    
    [self configElements];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentTextFieldDidEndEditing:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

#pragma make - Private Method
- (void)configElements {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:[UIColor commonBackgroundColor]];
    
    [self.tableView registerClass:[TransferAccountsTableViewCell class] forCellReuseIdentifier:[TransferAccountsTableViewCell at_identifier]];
    [self.tableView registerClass:[TransferAccountsAwardTableViewCell class] forCellReuseIdentifier:[TransferAccountsAwardTableViewCell at_identifier]];
    [self.tableView registerClass:[TransferAccountsNetWorkTableViewCell class] forCellReuseIdentifier:[TransferAccountsNetWorkTableViewCell at_identifier]];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:[UITableViewCell at_identifier]];
    [self.tableView registerClass:[TransferAccountsPasswordTableViewCell class] forCellReuseIdentifier:[TransferAccountsPasswordTableViewCell at_identifier]];
    [self.tableView registerClass:[TransferTotalCostTableViewCell class] forCellReuseIdentifier:[TransferTotalCostTableViewCell at_identifier]];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

// 在这个方法中，我们就可以通过自定义textField的indexPath属性区分不同行的cell，然后拿到textField.text
#pragma mark ======== 得到textField.text值
- (void)contentTextFieldDidEndEditing:(NSNotification *)noti {
    
    ZSCustomTextField *textField = noti.object;
    if (!textField.indexPath) {
        return;
    }
    NSString *text = textField.text;
    switch (textField.indexPath.section) {
        case TransferAccountsType_AddressSection:
            self.address = text;
            break;
        
        case TransferAccountsType_CountSection:
        {
            self.count = text;
            [self updateTotalCostData];
        }
            break;
            
        case TransferAccountsType_RemarkSection:
            self.remark = text;
            break;
            
        case TransferAccountsType_GasPriceSection:
            self.gasPrice = text;
            [self updateTotalCostData];
            break;
            
        case TransferAccountsType_GasSection:
            self.gasLimit = text;
            [self updateTotalCostData];
            break;
            
        case TransferAccountsType_PasWordSection:
            self.password = text;
            break;
            
        default:
            break;
    }
}

#pragma mark ============  检查上传参数
- (void)checkParam {
    if (kStringIsEmpty(self.address)) {
        showMessage(showTypeError, NSLocalizedString(@"请输入钱包地址", nil));
        return;
    }
    
    if (kStringIsEmpty(self.count)) {
        showMessage(showTypeError, NSLocalizedString(@"请输入数量", nil));
        return;
    }
    
    if (self.isAdvanceOn) {
        if (kStringIsEmpty(self.gasPrice)) {
            showMessage(showTypeError, NSLocalizedString(@"请输入Gas Price", nil));
            return;
        }
        
        if (kStringIsEmpty(self.gasLimit)) {
            showMessage(showTypeError, NSLocalizedString(@"请输入Gas Limit", nil));
            return;
        }
    }
    
    if (kStringIsEmpty(self.password)) {
        showMessage(showTypeError, NSLocalizedString(@"请输入钱包密码", nil));
        return;
    }
    
    //BigNumber *fee = [_transaction.gasLimit mul:_transaction.gasPrice];
    if ([_wallet activeToken].address != nil) {
        //仅当合约交易时候才设置，并且只有data不存在、改变时处理
        if (!_transaction.data.length) {
            SecureData *data = [SecureData secureDataWithCapacity:68];
            [data appendData:[SecureData hexStringToData:@"0xa9059cbb"]];
            
            NSData *dataAddress = _transaction.toAddress.data;
            for (int i=0; i < 32 - dataAddress.length; i++) {
                [data appendByte:'\0'];
            }
            [data appendData:dataAddress];
            
            NSData *valueData = _transaction.value.data;
            for (int i=0; i < 32 - valueData.length; i++) {
                [data appendByte:'\0'];
            }
            [data appendData:valueData];
            
            _transaction.value = [BigNumber constantZero];
            _transaction.data = data.data;
            _transaction.toAddress = _wallet.activeToken.address;
            _feeReady = NO;
        }
        
        if (_feeReady == NO) {
            __weak typeof(self) weakSelf = self;
            showMessage(showTypeStatus, NSLocalizedString(@"费用核算中...", nil));
            [self estimateGas:^(BigNumber *gas) {
                if (![self safeGasLimit]) {
                    NSString *str = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Gas Limit太低,已改为最低预估:", nil),_fuzzyEstimate.decimalString];
                    self.gasLimit = _fuzzyEstimate.decimalString;
                    _transaction.gasLimit = _fuzzyEstimate;
                    [weakSelf updateTotalCostData];
                    [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:TransferAccountsType_GasSection] withRowAnimation:UITableViewRowAnimationAutomatic];
                    showMessage(showTypeError, str);
                    _feeReady = NO;
                }else {
                    [weakSelf checkParam];
                }
            }];
            return;
        }else if(![self safeGasLimit]) {
            NSString *str = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Gas Limit太低,建议：", nil),_fuzzyEstimate.decimalString];
            showMessage(showTypeError, str);
            return;
        }else {
            //通过校验。
        }
    } else {
        _transaction.value = [self getTransactionValue:_count];
    }
    
        
    if ([_transaction.value compare:_signer.balance] != NSOrderedDescending) {
        if (_gasEstimate.integerValue!=25200&&![self safeGasLimit]) {
            showMessage(showTypeError, NSLocalizedString(@"Gas Limit太低", nil));
            return;
        }else {
            //maybe ok...
        }
    }else {
        showMessage(showTypeError, NSLocalizedString(@"余额不足", nil));
        return;
    }
    //验证钱包密码
    [SVProgressHUD showWithStatus:NSLocalizedString(@"密码验证中...", nil)];
    [_signer unlockPassword:self.password callback:^(Signer *signer, NSError *error) {
        
        [SVProgressHUD dismiss];
        // Expired unlock request
        if (error) {
            showMessage(showTypeError, NSLocalizedString(@"钱包密码错误", nil));
            
        } else {
            [self sendTransaction];
        }
    }];
}

- (void)estimateGas:(void (^)(BigNumber *))block {
        if (_transaction.toAddress && _transaction.value) {
    
            [[_signer.provider estimateGas:_transaction] onCompletion:^(BigNumberPromise *promise) {
                if (promise.error) {
//                    NSString *reason = [promise.error.userInfo valueForKey:@"reason"];
//                    showMessage(showTypeError, reason?:promise.error.localizedDescription);
//                    return;
                    _gasEstimate = [BigNumber bigNumberWithDecimalString:@"60000"];
                    _feeReady = YES;
                    block(_gasEstimate);
                    return ;
                }
                _gasEstimate = promise.value;
                _feeReady = YES;
    
                // Add 20% for good measure
                _fuzzyEstimate = [_gasEstimate div:[BigNumber bigNumberWithInteger:(100 / 20)]];
                _fuzzyEstimate = [_fuzzyEstimate add:_gasEstimate];
                block(_gasEstimate);
            }];
        }else{
            showMessage(showTypeError, NSLocalizedString(@"请输入转账金额", nil));
        }
}

- (void)setAddress:(NSString *)address {
    if ([_address isEqualToString:address]) {
        return;
    }
    _address = address;
    _transaction.toAddress = [Address addressWithString:address];
    _transaction.data = [SecureData secureDataWithCapacity:0].data;
}

- (void)setGasLimit:(NSString *)gasLimit {
    _gasLimit = gasLimit;
    _transaction.gasLimit = [BigNumber bigNumberWithDecimalString:gasLimit];
}

- (void)setGasPrice:(NSString *)gasPrice {
    _gasPrice = gasPrice;
    _transaction.gasPrice = [[BigNumber bigNumberWithDecimalString:gasPrice] mul:[BigNumber bigNumberWithDecimalString:@"1000000000"]];
}

- (void)setCount:(NSString *)count {
    _count = count;
    _transaction.value = [self getTransactionValue:count];
    _transaction.data = [SecureData secureDataWithCapacity:0].data;
}

- (BOOL)safeGasLimit {
    return ([_transaction.gasLimit compare:_fuzzyEstimate] != NSOrderedAscending);
}

- (BigNumber*)getTransactionValue: (NSString*)text {
    // Normalize to use a decimal place
    if ([[NSLocale currentLocale].decimalSeparator isEqualToString:@","]) {
        text = [text stringByReplacingOccurrencesOfString:@"," withString:@"."];
    }
    
    if (text.length == 0 || [text isEqualToString:@"."]) { text = @"0"; }
    
    return [Payment parseEther:text];
}

//- (BigNumber*)totalValue {
//    return [[_transaction.gasLimit mul:_transaction.gasPrice] add:_transaction.value?:[BigNumber constantZero]];
//}

#pragma mark ============  确认转账
- (void)sendTransaction {
    __weak typeof(self) weakSelf = self;
    [_signer send:weakSelf.transaction callback:^(Transaction *transaction, NSError *error) {
        if (error) {
            NSString *tip = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"失败",nil),error.localizedDescription];
            showMessage(showTypeError, tip);
        } else {
            // Lock the signer
            [weakSelf.signer lock];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (NSString*)getFiatValue {
    NSString *totalValue = self.count?:@"0";//[[Payment formatEther:wei] doubleValue] * [_wallet etherPrice];
//    if (costFiat > 100) {
//        return [NSString stringWithFormat:@"%.0f ETH", costFiat];
//    }
    return [NSString stringWithFormat:@"%@ %@\nGas:%@ ETH", totalValue,[_wallet activeToken].symbol,[Payment formatEther:[_transaction.gasPrice mul:_transaction.gasLimit]]];
}


#pragma mark -- 动态刷新 “总计耗费”
- (void)updateTotalCostData {
    if (_transaction.value && self.gasPrice && self.gasLimit) {
//        BigNumber *totalCost = [self totalValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTotalCostData" object:[self getFiatValue]];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TransferAccountsTypeMaxSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        switch (section) {
            case TransferAccountsType_GasPriceSection:
            case TransferAccountsType_GasSection:
                return self.isAdvanceOn?1:0;
            case TransferAccountsType_AwardSection:
                return self.isAdvanceOn?0:1;
        }
    return 1;
}

#pragma mark - TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //Advance 为OFF
    if (!self.isAdvanceOn) {
        switch (section) {
            case TransferAccountsType_GasPriceSection:
            case TransferAccountsType_GasSection:
            case TransferAccountsType_TotalCostSection:
            case TransferAccountsType_NetworkSection:
                return 0;
            
            case TransferAccountsType_PasWordSection:
                return 10;
                
            default:
                return 35;
        }
    }
    
    //Advance 为ON
    switch (section) {
        case TransferAccountsType_TotalCostSection:
        case TransferAccountsType_NetworkSection:
        case TransferAccountsType_AwardSection:
            return 0;
            
        case TransferAccountsType_PasWordSection:
            return 10;
    }
    return 35;
}

//区头的字体颜色设置
-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textColor = [UIColor commonWhiteColor];
//    header.textLabel.font = [UIFont systemFontOfSize:14.0f];
    header.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    header.contentView.backgroundColor = [UIColor commonBackgroundColor];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case TransferAccountsType_AddressSection:
            return NSLocalizedString(@"接收钱包地址",nil);
            
        case TransferAccountsType_CountSection:
            return [NSString stringWithFormat:@"%@（%@ %.2f %@）",NSLocalizedString(@"转账数量",nil),NSLocalizedString(@"余额",nil),[[Payment formatEther:[_wallet activeToken].balance] doubleValue],[_wallet activeToken].symbol];
            
        case TransferAccountsType_AwardSection:
            return NSLocalizedString(@"矿工奖励",nil);
            
        case TransferAccountsType_RemarkSection:
            return NSLocalizedString(@"交易备注",nil);
            
        case TransferAccountsType_GasPriceSection:
            return @"Gas Price(gwei)";
        
        case TransferAccountsType_GasSection:
            return @"Gas Limit";
    }
    return @" ";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case TransferAccountsType_NetworkSection:
        case TransferAccountsType_AwardSection:
            return 80;
            
        case TransferAccountsType_TotalCostSection:
            return 60;
            
        case TransferAccountsType_ConfirmSection:
            return 85;
            
        default:
            break;
    }
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TransferAccountsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[TransferAccountsTableViewCell at_identifier]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.txtField.indexPath = indexPath;
    
    switch (indexPath.section) {
        case TransferAccountsType_AddressSection:
        {
            [cell setTransferAccountsTableViewCellType:TableViewCellType_Image];
            cell.txtField.placeholder = NSLocalizedString(@"填入接收钱包地址（可扫描）",nil);
            if (cell.txtField.text) {
                cell.txtField.text = self.address;
            }
            break;
        }
            
        case TransferAccountsType_CountSection:
        {
            [cell setTransferAccountsTableViewCellType:TableViewCellType_Text];
            cell.txtField.placeholder = NSLocalizedString(@"填入数量",nil);
            cell.txtField.keyboardType = UIKeyboardTypeDecimalPad;
            if (cell.txtField.text) {
                cell.txtField.text = self.count;
            }
            cell.promptLb.text = [_wallet activeToken].symbol;
            break;
        }
            
        case TransferAccountsType_AwardSection:
            return [self setTransferAccountsAwardTableViewCell];
            break;
            
        case TransferAccountsType_RemarkSection:
        {
            cell.txtField.placeholder = NSLocalizedString(@"交易备注",nil);
            [cell setTransferAccountsTableViewCellType:TableViewCellType_None];
            if (cell.txtField.text) {
                cell.txtField.text = self.remark;
            }
            break;
        }
            
        case TransferAccountsType_GasPriceSection:
        {
            [cell setTransferAccountsTableViewCellType:TableViewCellType_None];
            cell.txtField.placeholder = NSLocalizedString(@"自定义Gas Price,一般为(20~100)Gwei",nil);
            cell.txtField.keyboardType = UIKeyboardTypeDecimalPad;
            if (cell.txtField.text) {
                cell.txtField.text = self.gasPrice;
            }
            break;
        }
            
        case TransferAccountsType_GasSection:
        {
            [cell setTransferAccountsTableViewCellType:TableViewCellType_None];
            cell.txtField.placeholder = NSLocalizedString(@"自定义Gas Limit,ETH转账为21000,代币或合约按需填写",nil);
            cell.txtField.keyboardType = UIKeyboardTypeNumberPad;
            if (cell.txtField.text) {
                cell.txtField.text = self.gasLimit;
            }
            break;
        }
            
        case TransferAccountsType_NetworkSection:
            return [self setTransferAccountsNetWorkTableViewCell];
            break;
            
        case TransferAccountsType_TotalCostSection:
            return [self setTotalCostTableViewCell];
            break;
            
        case TransferAccountsType_PasWordSection:
            return [self setTransferAccountsPasswordTableViewCell:indexPath];
            break;
            
        case TransferAccountsType_ConfirmSection:
            return [self setConfirmTableViewCell];
            break;
            
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case TransferAccountsType_AddressSection:
        {
            //跳转扫描二维码
//            ScanQRCodeViewController *scanVC = [[ScanQRCodeViewController alloc] init];
//            scanVC.block = ^(NSString *address) {
//                self.address = address;
//
//                NSIndexSet *indexSet=[[NSIndexSet alloc] initWithIndex:TransferAccountsType_AddressSection];
//                [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
//            };
            Signer *signer = [_wallet signer];
            ScannerConfigController *scanVC = [ScannerConfigController configWithSigner:signer];
            __weak ScannerConfigController *weakScanner = scanVC;
            void (^onComplete)(void) = ^() {
                dispatch_async(dispatch_get_main_queue(), ^() {
                    [weakScanner startScanningAnimated:YES];
                });
            };
//            [self.navigationController presentViewController:scanVC animated:YES completion:onComplete];
            ZSBaseNavigationViewController *navigationController = [[ZSBaseNavigationViewController alloc] initWithRootViewController:scanVC];
            [self presentViewController:navigationController animated:YES completion:onComplete];

            scanVC.block = ^(NSString *address) {
                self.address = address;
                self.count = [Payment formatEther:weakScanner.foundAmount];

                NSIndexSet *indexSet=[[NSIndexSet alloc] initWithIndex:TransferAccountsType_AddressSection];
                [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                indexSet=[[NSIndexSet alloc] initWithIndex:TransferAccountsType_CountSection];
                [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                [self updateTotalCostData];
            };
            break;
        }
            
        case TransferAccountsType_ConfirmSection:
        {
            //确认转账
            [self checkParam];
        }
            
        default:
            break;
    }
}
#pragma mark - Cell
- (TransferAccountsAwardTableViewCell *)setTransferAccountsAwardTableViewCell {
    
    __weak typeof(self) weakSelf = self;
    TransferAccountsAwardTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[TransferAccountsAwardTableViewCell at_identifier]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell updateValue:self.gasPrice];
    cell.blockValue = ^(int value) {
        weakSelf.gasPrice = [NSString stringWithFormat:@"%d",value];
        [weakSelf updateTotalCostData];
        [weakSelf.tableView reloadData];
    };
    return cell;
}

- (TransferAccountsNetWorkTableViewCell *)setTransferAccountsNetWorkTableViewCell {
    
    TransferAccountsNetWorkTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[TransferAccountsNetWorkTableViewCell at_identifier]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    __weak typeof(self) weakSelf = self;
    cell.block = ^(NSInteger index) {
        if (index == 0) {
            weakSelf.isAdvanceOn = YES;
        }
        else {
            weakSelf.isAdvanceOn = NO;
        }
        [weakSelf.tableView reloadData];
    };
    return cell;
}

- (UITableViewCell *)setTransferAccountsPasswordTableViewCell:(NSIndexPath *)indexPath {
    TransferAccountsPasswordTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[TransferAccountsPasswordTableViewCell at_identifier]];
    cell.txtField.indexPath = indexPath;
    cell.txtField.placeholder = NSLocalizedString(@"填入钱包密码",nil);
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (UITableViewCell *)setTotalCostTableViewCell {
    
    TransferTotalCostTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[TransferTotalCostTableViewCell at_identifier]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (UITableViewCell *)setConfirmTableViewCell {

    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[UITableViewCell at_identifier]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor commonBackgroundColor]];

    UILabel *txtLb = [UILabel new];
    [cell.contentView addSubview:txtLb];
    txtLb.text = NSLocalizedString(@"确认转账",nil);
    txtLb.textColor = [UIColor commonWhiteColor];
    txtLb.textAlignment = NSTextAlignmentCenter;
    txtLb.backgroundColor = [UIColor commonCellcolor];
    txtLb.layer.masksToBounds = YES;
    txtLb.layer.cornerRadius = 5.0f;
    [txtLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(cell.contentView).insets(UIEdgeInsetsMake(0, 20, 30, 20));
    }];
    return cell;
}
@end
