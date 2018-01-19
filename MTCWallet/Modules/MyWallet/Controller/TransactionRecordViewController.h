//
//  TransactionRecordViewController.h
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/2.
//  Copyright © 2018年 lkl. All rights reserved.
//  交易记录

#import "ZSBasePageViewController.h"


typedef NS_ENUM(NSInteger, TransactionRecordSection){
    TransactionRecordSection_Send,
    TransactionRecordSection_Recive,
    TransactionRecordMaxSection,
};
@interface TransactionRecordViewController : ZSBasePageViewController

@end
