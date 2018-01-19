//
//  CurrencyDetailsViewController.h
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/2.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "ZSBasePageViewController.h"

@interface CurrencyDetailsViewController : ZSBasePageViewController

@property (nonatomic, readonly) Wallet *wallet;
- (instancetype)initWithWallet:(Wallet*)wallet;

@property (nonatomic, readonly) Address *accountAddress;
@property (nonatomic, readonly) ChainId accountChainId;
@end
