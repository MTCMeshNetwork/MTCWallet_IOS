//
//  TransactionDetailTableViewCell.m
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/4.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "TransactionDetailTableViewCell.h"

@interface TransactionDetailTableViewCell ()

@property (nonatomic, strong) UILabel *coinLb;
@property (nonatomic, strong) UILabel *promptLb;
@end

@implementation TransactionDetailTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView setBackgroundColor:[UIColor commonCellcolor]];
        
        self.coinLb = [UILabel new];
        [self.contentView addSubview:self.coinLb];
        [self.coinLb setFont:[UIFont systemFontOfSize:28.0f]];
        
        [self.coinLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.top.equalTo(self.contentView).offset(20);
        }];

        self.promptLb = [UILabel new];
        [self.contentView addSubview:self.promptLb];
        [self.promptLb setTextColor:[UIColor whiteColor]];
        [self.promptLb setFont:[UIFont systemFontOfSize:15.0f]];
        
        [self.promptLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView).offset(-20);
        }];
    }
    return self;
}

- (void)setAddress:(Address*)address blockNumber:(NSUInteger)blockNumber transactionInfo: (TransactionInfo *)transactionInfo {

    [self.coinLb setTextColor:[UIColor commonGreenColor]];
    [self.coinLb setAttributedText:[NSAttributedString getAttributWithString:@"0.0 ETH" UnChangePart:@"0.0 " changePart:@"ETH" changeColor:nil changeFont:[UIFont systemFontOfSize:13.0f]]];
    
    
    [self.promptLb setText:NSLocalizedString(@"转账成功",nil)];
    
    if (transactionInfo.blockNumber == -1) {
        //pending
        self.promptLb.text = @"广播中";
    }
    else {
        int confirmations = (int)(blockNumber - transactionInfo.blockNumber + 1);
        if (confirmations < 12) {
            //inProgress
            self.promptLb.text = @"交易中";
        }
        else {
            //confirmed
            self.promptLb.text = @"成功";
        }
    }
    
    BigNumber *value = transactionInfo.value;
    if (_transactionInfo.contractAddress) {
        value = [value mul:[BigNumber constantNegativeOne]];
    }
    else if ([_transactionInfo.fromAddress isEqualToAddress:_address]) {
        self.coinLb.textColor = [UIColor commonRedColor];
        value = [value mul:[BigNumber constantNegativeOne]];
    }
    
    [self setBalance:value];
}

- (void)setBalance:(BigNumber *)balance {
    if (!balance) { balance = [BigNumber constantZero]; }
    
    NSString *string = [Payment formatEther:balance
                                    options:(EtherFormatOptionCommify | EtherFormatOptionApproximate)];
    
    self.coinLb.text = string;
}

@end
