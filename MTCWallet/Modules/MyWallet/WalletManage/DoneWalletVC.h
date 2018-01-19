//
//  DoneWalletVC.h
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/5.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Account;

@interface DoneWalletVC : UITableViewController

- (instancetype)initWithAccount:(Account *)account password:(NSString *)password;

@property (nonatomic, copy) void (^onFinish)(DoneWalletVC*);

@property (nonatomic, strong) NSString *json;
@property (nonatomic, strong) NSString *name, *hint;

@end
