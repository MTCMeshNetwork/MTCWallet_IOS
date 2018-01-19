//
//  SwitchView.h
//  ZSEthersWallet
//
//  Created by L on 2018/1/7.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchView : UIView

@property (nonatomic, strong) UILabel *titleLb;
@property (nonatomic, strong) UILabel *detailLb;

- (void)setSwitchViewTitle:(NSString *)title detail:(NSString *)str;

@end
