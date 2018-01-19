//
//  ScanQRCodeViewController.h
//  ZSEthersWallet
//
//  Created by L on 2018/1/5.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "ZSBasePageViewController.h"

typedef void (^walletAddressBlock)(NSString *);

@interface ScanQRCodeViewController : ZSBasePageViewController

@property (nonatomic, copy) walletAddressBlock block;

@end
