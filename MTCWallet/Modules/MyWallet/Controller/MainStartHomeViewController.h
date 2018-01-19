//
//  MainStartHomeViewController.h
//  ZSEthersWallet
//
//  Created by thomasho on 2017/12/28.
//  Copyright © 2017年 lkl. All rights reserved.
//

#import "ZSBasePageViewController.h"
#import "Wallet.h"

@interface MainStartHomeViewController : ZSBasePageViewController

@property (nonatomic, readonly) Wallet *wallet;

@property (nonatomic, readonly) Address *accountAddress;
@property (nonatomic, readonly) ChainId accountChainId;

@end
