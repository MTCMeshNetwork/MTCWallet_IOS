//
//  TransferAccountsTableViewCell.h
//  ZSEthersWallet
//
//  Created by L on 2018/1/5.
//  Copyright © 2018年 lkl. All rights reserved.
//  转账

#import <UIKit/UIKit.h>
#import "ZSCustomTextField.h"

typedef NS_ENUM(NSUInteger, TableViewCellType) {
    TableViewCellType_Image,
    TableViewCellType_Text,
    TableViewCellType_None,
};

@interface TransferAccountsTableViewCell : UITableViewCell

@property (nonatomic, strong) ZSCustomTextField *txtField;
@property (nonatomic, strong) UILabel *promptLb;
@property (nonatomic, strong) UIImageView *scanImgView;

- (void)setTransferAccountsTableViewCellType:(TableViewCellType)type;
@end

// 矿工奖励
typedef void(^SliderBlock) (int value);
@interface TransferAccountsAwardTableViewCell : UITableViewCell
@property (nonatomic, copy) SliderBlock blockValue;
- (void)updateValue:(NSString *)value;
@end

// network

typedef void(^segmentedControlBlock) (NSInteger index);

@interface TransferAccountsNetWorkTableViewCell : UITableViewCell

@property (nonatomic, copy) segmentedControlBlock block;
@end

//总计耗费
@interface TransferTotalCostTableViewCell : UITableViewCell

@end

// 交易密码
@interface TransferAccountsPasswordTableViewCell : TransferAccountsTableViewCell

@end

