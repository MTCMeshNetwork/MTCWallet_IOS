//
//  ScannerConfigController.h
//  EthersWallet
//
//  Created by Richard Moore on 2017-08-23.
//  Copyright © 2017 ethers.io. All rights reserved.
//

#import "ZSBasePageViewController.h"
#import "ConfigController.h"

#import "Signer.h"

typedef void (^walletAddressBlock)(NSString *);

@interface ScannerConfigController : ZSBasePageViewController

+ (instancetype)configWithSigner: (Signer*)signer;

@property (nonatomic, readonly) Signer *signer;


- (void)startScanningAnimated:(BOOL)animated;

@property (nonatomic, readonly) NSString *foundName;
@property (nonatomic, readonly) Address *foundAddress;
@property (nonatomic, readonly) BigNumber *foundAmount;

@property (nonatomic, copy) walletAddressBlock block;
@end
