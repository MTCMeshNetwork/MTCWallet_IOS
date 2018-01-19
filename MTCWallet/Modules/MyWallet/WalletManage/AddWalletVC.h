//
//  AddWalletVC.h
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/5.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "ConfigController.h"

@interface AddWalletVC : UITableViewController

@property (nonatomic, copy) void (^onReturn)(AddWalletVC*,NSString*,NSString*,NSString*);

@end
