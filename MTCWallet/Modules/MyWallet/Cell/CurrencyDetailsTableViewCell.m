//
//  CurrencyDetailsTableViewCell.m
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/2.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "CurrencyDetailsTableViewCell.h"
#import "Utilities.h"

static NSDateFormatter *DateFormat = nil;
static NSDateFormatter *TimeFormat = nil;

NSAttributedString *getTimestamp1(NSTimeInterval timestamp) {
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

@interface CurrencyDetailsTableViewCell ()

//@property (nonatomic, strong) UIView *colorView;
//@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *addressLb;
@property (nonatomic, strong) UILabel *tradeDateLb;
@property (nonatomic, strong) UILabel *coinLb;
@property (nonatomic, strong) UILabel *statusLb;

@end

@implementation CurrencyDetailsTableViewCell

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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView setBackgroundColor:[UIColor commonCellcolor]];
        
        [self.contentView addSubview:self.addressLb];
        [self.contentView addSubview:self.tradeDateLb];
        [self.contentView addSubview:self.coinLb];
        [self.contentView addSubview:self.statusLb];
        
        [self.addressLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.contentView).offset(15);
            make.width.equalTo(@150);
        }];
        
        [self.tradeDateLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.addressLb.mas_left);
            make.bottom.equalTo(self.contentView).offset(-15);
        }];
        
        [self.coinLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.addressLb.mas_top);
            make.right.equalTo(self.contentView).offset(-10);
        }];
        
        [self.statusLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.tradeDateLb.mas_bottom);
            make.right.equalTo(self.coinLb.mas_right);
        }];
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noticeTransactionUpdated:) name:WalletTransactionDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)noticeTransactionUpdated: (NSNotification*)note {
    TransactionInfo *transactionInfo = [note.userInfo objectForKey:@"transaction"];
    if (_transactionInfo && [transactionInfo.transactionHash isEqualToHash:_transactionInfo.transactionHash]) {
        [self setWallet:_wallet transactionInfo:transactionInfo];
    }
    if (self.statusLb.tag) {
        int confirmations = (int)(_wallet.activeAccountBlockNumber - _transactionInfo.blockNumber + 1);
        if (confirmations < 12) {
            //inProgress
            self.statusLb.text = [NSString stringWithFormat:@"%@(%d/12)",NSLocalizedString(@"正在确认", nil),confirmations];
        }
        else {
            //confirmed
            self.statusLb.text = _transactionInfo.isError?NSLocalizedString(@"交易失败",nil):NSLocalizedString(@"交易成功",nil);
            if (_transactionInfo.isError == 1) {
                self.statusLb.textColor = [UIColor commonRedColor];
            }else {
                self.statusLb.textColor = [UIColor commonWhiteColor];
            }
        }
    }
}


#pragma mark ==== 交易记录

- (void)setWallet:(Wallet *)wallet transactionInfo: (TransactionInfo *)transactionInfo {
    //_wallet.activeAccountAddress token:_wallet.activeToken.address blockNumber:_wallet.activeAccountBlockNumber
    _wallet = wallet;
    _transactionInfo = transactionInfo;
    
    NSInteger blockNumber = wallet.activeAccountBlockNumber;
    Address *tokenAddress = wallet.activeToken.address;
    Address *accountAddress = wallet.activeAccountAddress;
    self.statusLb.tag = 0;
    if (transactionInfo.blockNumber == -1) {
        //pending
        self.statusLb.text =NSLocalizedString(@"广播中",nil);
    }
    else {
        int confirmations = (int)(blockNumber - transactionInfo.blockNumber + 1);
        if (confirmations < 12) {
            //inProgress
            self.statusLb.text = [NSString stringWithFormat:@"%@(%d/12)",NSLocalizedString(@"正在确认", nil),confirmations];
            self.statusLb.tag = 1;
        }
        else {
            //confirmed
            self.statusLb.text = _transactionInfo.isError?NSLocalizedString(@"交易失败",nil):NSLocalizedString(@"交易成功",nil);
            if (_transactionInfo.isError == 1) {
                self.statusLb.textColor = [UIColor commonRedColor];
            }else {
                self.statusLb.textColor = [UIColor commonWhiteColor];
            }
        }
    }
    
    BigNumber *value = transactionInfo.value;
    Address *toAddress = transactionInfo.toAddress;
    
    //代币合约列表
    if (tokenAddress) {
        //解析自定义data
        toAddress = _transactionInfo.tokenTo;
        value = _transactionInfo.tokenValue;
    }
    
    if ([toAddress isEqualToAddress:accountAddress]) {
        //接收
        self.coinLb.textColor = [UIColor commonGreenColor];
        if ([_transactionInfo.fromAddress isEqualToAddress:accountAddress]) {
            //self
            self.addressLb.text = @"self";
//            self.statusLb.text = @"";
        } else {
            //Received
            self.addressLb.text = _transactionInfo.fromAddress.checksumAddress;
        }

    } else {
        //转出eth
        self.coinLb.textColor = [UIColor commonRedColor];
        if (_transactionInfo.contractAddress) {
            self.addressLb.text =toAddress.checksumAddress?:_transactionInfo.contractAddress.checksumAddress;
//            self.statusLb.text = @"Contract";
            value = [value mul:[BigNumber constantNegativeOne]];
        } else if ([_transactionInfo.fromAddress isEqualToAddress:accountAddress]) {
            self.addressLb.text = toAddress.checksumAddress;
            value = [value mul:[BigNumber constantNegativeOne]];
//            self.statusLb.text = @"send";

        } else {
            self.addressLb.text = toAddress.checksumAddress;
//            self.statusLb.text = @"unknown";
        }
    }

    self.tradeDateLb.attributedText = getTimestamp1(transactionInfo.timestamp);

    [self setBalance:value];
}

- (void)setBalance:(BigNumber *)balance {
    if (!balance) { balance = [BigNumber constantZero]; }
    
    NSString *string = [Payment formatEther:balance
                                    options:(EtherFormatOptionCommify | EtherFormatOptionApproximate)];
    
    self.coinLb.text = string;
}

#pragma mark - Init
//- (UIView *)colorView {
//    if (!_colorView) {
//        _colorView = [UIView new];
//        _colorView.backgroundColor = [UIColor commonGreenColor];
//    }
//    return _colorView;
//}
//
//- (UIImageView *)imgView {
//    if (!_imgView) {
//        _imgView = [UIImageView new];
//    }
//    return _imgView;
//}

- (UILabel *)addressLb {
    if (!_addressLb) {
        _addressLb = [UILabel new];
        _addressLb.font = [UIFont systemFontOfSize:15.0f];
        _addressLb.textColor = [UIColor whiteColor];
        _addressLb.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _addressLb;
}

- (UILabel *)tradeDateLb {
    if (!_tradeDateLb) {
        _tradeDateLb = [UILabel new];
        _tradeDateLb.font = [UIFont systemFontOfSize:15.0f];
        _tradeDateLb.textColor = [UIColor commonWhiteColor];
    }
    return _tradeDateLb;
}

- (UILabel *)coinLb {
    if (!_coinLb) {
        _coinLb = [UILabel new];
        _coinLb.font = [UIFont systemFontOfSize:15.0f];
        _coinLb.textColor = [UIColor whiteColor];
    }
    return _coinLb;
}

- (UILabel *)statusLb {
    if (!_statusLb) {
        _statusLb = [UILabel new];
        _statusLb.font = [UIFont systemFontOfSize:15.0f];
        _statusLb.textColor = [UIColor commonWhiteColor];
    }
    return _statusLb;
}
@end
