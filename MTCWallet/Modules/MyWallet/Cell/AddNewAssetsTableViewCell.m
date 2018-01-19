//
//  AddNewAssetsTableViewCell.m
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/4.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "AddNewAssetsTableViewCell.h"

@interface AddNewAssetsTableViewCell ()
@end

@implementation AddNewAssetsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView setBackgroundColor:[UIColor commonCellcolor]];
        [self.contentView addSubview:self.coinImg];
        [self.contentView addSubview:self.currencyLb];
        [self.contentView addSubview:self.showSwitch];
        
//        [self.coinImg setImage:[UIImage imageNamed:@"BTC"]];
        [self.coinImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(33, 33));
        }];
        
        [self.currencyLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.coinImg.mas_right).offset(10);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.showSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-15);
        }];
    }
    return self;
}


- (void)swChange:(UISwitch*) sw{
    
    if(sw.on==YES){
        NSLog(@"开关被打开");
    }else{
        NSLog(@"开关被关闭");
    }
}

- (UIImageView *)coinImg {
    if (!_coinImg) {
        _coinImg = [UIImageView new];
    }
    return _coinImg;
}
- (UILabel *)currencyLb {
    if (!_currencyLb) {
        _currencyLb = [UILabel new];
        _currencyLb.textColor = [UIColor commonWhiteColor];
    }
    return _currencyLb;
}

- (UISwitch *)showSwitch {
    if (!_showSwitch) {
        _showSwitch = [UISwitch new];
        _showSwitch.on=YES;
//        [_showSwitch setOnTintColor:[UIColor lightGrayColor]];
//        [_showSwitch setThumbTintColor:[UIColor blueColor]];
        [_showSwitch setTintColor:[UIColor lightGrayColor]];
        [_showSwitch addTarget:self action:@selector(swChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _showSwitch;
}
@end
