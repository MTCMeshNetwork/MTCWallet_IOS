//
//  CurrencyDetailsTableViewCell.h
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/2.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ethers/TransactionInfo.h>

@interface CurrencyDetailsTableViewCell : UITableViewCell

- (void)setAddress: (Address*)address blockNumber:(NSUInteger)blockNumber transactionInfo: (TransactionInfo*)transactionInfo;

@property (nonatomic, readonly) Address *address;
@property (nonatomic, readonly) TransactionInfo *transactionInfo;

@end
