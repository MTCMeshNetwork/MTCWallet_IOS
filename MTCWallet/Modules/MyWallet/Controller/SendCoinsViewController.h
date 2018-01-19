//
//  SendCoinsViewController.h
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/2.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "ZSBasePageViewController.h"
#import "Signer.h"

@class Transaction;

@interface SendCoinsViewController : UITableViewController

- (instancetype)initWithWallet:(Wallet*)wallet;

@property (nonatomic, readonly) Wallet *wallet;
@property (nonatomic, readonly) Signer *signer;
@property (nonatomic, readonly) NSString *nameHint;

@end
