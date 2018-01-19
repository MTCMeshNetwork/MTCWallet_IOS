//
//  TransactionDetailsViewController.m
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/4.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "TransactionDetailsViewController.h"
#import "TransactionDetailTableViewCell.h"
#import "CurrencyDetailsViewController.h"
#import "Utilities.h"

static NSDateFormatter *DateFormat = nil;
static NSDateFormatter *TimeFormat = nil;

NSAttributedString *getTimestamp2(NSTimeInterval timestamp) {
    NSDate *dateObject = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
    NSString *date = [DateFormat stringFromDate:dateObject];
    NSString *time = [TimeFormat stringFromDate:dateObject];
    
    NSString *string = [NSString stringWithFormat:@"%@ %@", date, time];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString setAttributes:@{
                                      NSFontAttributeName: [UIFont fontWithName:FONT_NORMAL size:13.0f],
                                      }
                              range:NSMakeRange(0, date.length)];
    [attributedString setAttributes:@{
                                      NSFontAttributeName: [UIFont fontWithName:FONT_BOLD size:13.0f],
                                      }
                              range:NSMakeRange(date.length + 1, string.length - date.length - 1)];
    return attributedString;
}

// 交易详情类型
typedef NS_ENUM(NSUInteger, TransactionType) {
    TransactionType_Collection,   //收款
    TransactionType_Transfer,     //转账
};

typedef NS_ENUM(NSUInteger, TransactionDetail) {
    TransactionDetail_SituationSection,
    TransactionDetail_DetailSection,
    TransactionDetail_OtherSection,
    TransactionDetail_AddressSection,
    TransactionDetailMaxSection,
};

@interface TransactionDetailsViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, assign) NSUInteger blockNumber;
@property (nonatomic, copy) NSString *tradeType;
@end

@implementation TransactionDetailsViewController

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DateFormat = [[NSDateFormatter alloc] init];
        DateFormat.locale = [NSLocale currentLocale];
        [DateFormat setDateFormat:@"yyyy-MM-dd"];
        
        TimeFormat = [[NSDateFormatter alloc] init];
        TimeFormat.locale = [NSLocale currentLocale];
        [TimeFormat setTimeStyle:NSDateFormatterShortStyle];
        
        // @TODO: Add notification to regenerate these on local change
    });
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"交易详情",nil);
    [self configElements];
}


#pragma make - Private Method
- (void)configElements {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)setAddress:(Address*)address blockNumber:(NSUInteger)blockNumber transactionInfo: (TransactionInfo *)transactionInfo {
    
    _address = address;
    _transactionInfo = transactionInfo;
    self.blockNumber = blockNumber;
    
    if ([transactionInfo.toAddress isEqualToAddress:_address]) {
        if ([_transactionInfo.fromAddress isEqualToAddress:_address]) {
            self.tradeType = @"-";
        } else {
            self.tradeType = @"Received";
        }
        
    } else {
        if (_transactionInfo.contractAddress) {
            self.tradeType = @"Sent";
            
        } else if ([_transactionInfo.fromAddress isEqualToAddress:_address]) {
            self.tradeType = @"Sent";
            
        } else {
            self.tradeType = @"unknown";
        }
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TransactionDetailMaxSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    switch (section) {
        case TransactionDetail_SituationSection:
            return 1;
            break;
            
        case TransactionDetail_DetailSection:
            return 5;
            break;
            
        case TransactionDetail_OtherSection:
            return 4;
            break;
            
        case TransactionDetail_AddressSection:
            return 1;
            break;
            
        default:
            break;
    }
    return 0;
}

#pragma mark - TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor commonBackgroundColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TransactionDetail_SituationSection) {
        return 110;
    }
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell at_identifier]];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[UITableViewCell at_identifier]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor = [UIColor commonCellcolor];
        cell.textLabel.textColor = [UIColor commonWhiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        
        cell.detailTextLabel.text = NSLocalizedString(@"测试数据",nil);
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
        cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    
    switch (indexPath.section) {
        case TransactionDetail_SituationSection:
        {
            TransactionDetailTableViewCell *transactionCell = [tableView dequeueReusableCellWithIdentifier:[TransactionDetailTableViewCell at_identifier]];
            [transactionCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [transactionCell setAddress:_address blockNumber:self.blockNumber transactionInfo:_transactionInfo];
            return transactionCell;
            break;
        }
            
        case TransactionDetail_DetailSection:
        {
            NSArray *titleArray = @[@"交易类型",@"付款钱包",@"收款钱包",@"交易时间",@"交易备注"];
            [cell.textLabel setText:titleArray[indexPath.row]];

            if (indexPath.row == 0) {   //交易类型
                [cell.detailTextLabel setText: self.tradeType];
            }
            else if (indexPath.row == 1) {   //付款钱包
                [cell.detailTextLabel setText: _transactionInfo.fromAddress.checksumAddress];
            }
            else if (indexPath.row == 2) {   //收款钱包
                [cell.detailTextLabel setText: _transactionInfo.toAddress.checksumAddress];
            }
            else if (indexPath.row == 3) {   //交易时间
                [cell.detailTextLabel setAttributedText:getTimestamp2(_transactionInfo.timestamp)];
            }
            else if (indexPath.row == 4) {   //交易备注
                [cell.detailTextLabel setText: @"-"];
            }
            break;
        }
            
        case TransactionDetail_OtherSection:
        {
            NSArray *titleArray = @[@"网络",@"区块高度",@"Gas Limit",@"Gas Price"];
            [cell.textLabel setText:titleArray[indexPath.row]];
            [cell.detailTextLabel setText:@"-"];
            if (indexPath.row == 0) {     //网络
                [cell.detailTextLabel setText:@"ETH"];
            }
            else if (indexPath.row == 1) {    //区块高度
                [cell.detailTextLabel setText:[NSString stringWithFormat:@"%ld",_transactionInfo.blockNumber]];
            }
            else if (indexPath.row == 2) {    //Gas limit
                [cell.detailTextLabel setText:_transactionInfo.gasLimit.decimalString];
            }
            else if (indexPath.row == 3) {    // Gas
                [cell.detailTextLabel setText:_transactionInfo.gasPrice.decimalString];
            }
            break;
        }
            
        case TransactionDetail_AddressSection:
        {
            [cell.textLabel setText:NSLocalizedString(@"交易号",nil)];
            
            if(_transactionInfo.transactionHash.isZeroHash) {
                [cell.detailTextLabel setText:NSLocalizedString(@"广播中", nil)];
            } else {
                [cell.detailTextLabel setText:_transactionInfo.transactionHash.hexString];
            }
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            break;
        }
            
        default:
            break;
    }
    

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == TransactionDetail_AddressSection) {
        UIViewController *vc = [[UIViewController alloc] initWithNibName:nil bundle:nil];
        vc.title = NSLocalizedString(@"查询交易", nil);
        UIWebView *web = [[UIWebView alloc] init];
        [vc.view addSubview:web];
        [web mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(vc.view);
        }];
        [self.navigationController pushViewController:vc animated:YES];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *hashBlock = cell.detailTextLabel.text;
        [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://etherscan.io/tx/%@",hashBlock]]]];
    }
}


#pragma mark - Init
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setBackgroundColor:[UIColor commonBackgroundColor]];
        [_tableView registerClass:[TransactionDetailTableViewCell class] forCellReuseIdentifier:[TransactionDetailTableViewCell at_identifier]];
    }
    return _tableView;
}

@end
