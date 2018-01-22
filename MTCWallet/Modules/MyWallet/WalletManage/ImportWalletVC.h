//
//  ImportWalletVC.h
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/5.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSBasePageViewController.h"

@interface Mnemonic:NSObject
@property (nonatomic,strong) NSString *mnemonics;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *path;
@property (nonatomic,strong) NSString *pwd;
@property (nonatomic,strong) NSString *pwdRetry;
@property (nonatomic,strong) NSString *hint;
@end

@interface KeyStore:NSObject
@property (nonatomic,strong) NSString *json;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *pwd;
@end

@interface PrivateKey:NSObject
@property (nonatomic,strong) NSString *key;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *pwd;
@property (nonatomic,strong) NSString *pwdRetry;
@property (nonatomic,strong) NSString *hint;
@end

@interface ImportWalletVC : ZSBasePageViewController

@property (nonatomic, copy) void (^didImportMnemonic)(ImportWalletVC*,Mnemonic *);
@property (nonatomic, copy) void (^didImportKeystore)(ImportWalletVC*,KeyStore *);
@property (nonatomic, copy) void (^didImportPrivateKey)(ImportWalletVC*,PrivateKey *);

@end
