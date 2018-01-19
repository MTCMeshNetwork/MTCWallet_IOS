//
//  WalletManagerView.h
//  ZSEthersWallet
//
//  Created by L on 2018/1/7.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSCustomButton.h"

@interface WalletManagerView : UIView
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *popupView;
@property (nonatomic, strong) UILabel *titleLb;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) ZSCustomButton *createBtn, *importBtn;
@property (nonatomic, strong) UITableView *tableView;

- (void)showWithAnimation:(BOOL)animation;
@end
