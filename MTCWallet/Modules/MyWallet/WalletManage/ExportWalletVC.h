//
//  ExportVC.h
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/7.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ethers/Account.h>

typedef NS_ENUM(NSUInteger, ExportType) {
    ExportTypeMnmenic = 1,
    ExportTypeKeyStore,
    ExportTypePrivateKey,
    ExportTypeMnmenicConfirm,
};

@interface ExportWalletVC : UITableViewController

+ (ExportWalletVC *)export:(NSString *)content withType:(ExportType)type;

@end
