//
//  MainStartHomeTableViewCell.m
//  ZSEthersWallet
//
//  Created by thomasho on 2017/12/29.
//  Copyright © 2017年 lkl. All rights reserved.
//

#import "MainStartHomeTableViewCell.h"
#import "UIImage+IconFont.h"
#import "Utilities.h"
#import "CachedDataStore.h"
#import "BalanceLabel.h"
@interface MainStartHomeTableViewCell ()

//@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIImageView *coinImg;
@property (nonatomic, strong) UILabel *symbolLbl;
@property (nonatomic, strong) BalanceLabel *balenceLbl;
@property (nonatomic, strong) UILabel *assetLbl;
//@property (nonatomic, strong) UIView *rightView;

@end

@implementation MainStartHomeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView setBackgroundColor:[UIColor commonCellcolor]];
        
//        [self.contentView addSubview:self.leftView];
        [self.contentView addSubview:self.coinImg];
        [self.contentView addSubview:self.balenceLbl];
        [self.contentView addSubview:self.assetLbl];
        [self.contentView addSubview:self.symbolLbl];
//        [self.contentView addSubview:self.rightView];
        
//        [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.top.bottom.equalTo(self.contentView);
//            make.width.mas_equalTo(@5);
//        }];
        
        [self.coinImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(33, 33));
        }];
        [self.symbolLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.coinImg.mas_right).offset(10);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.balenceLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(10);
            make.right.equalTo(self.contentView).offset(-15);
            make.left.equalTo(self.symbolLbl.mas_right);
            make.height.equalTo(@20);
        }];
        
        [self.assetLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-10);
            make.right.equalTo(self.contentView).offset(-15);
        }];
        
//        [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.top.bottom.equalTo(self.contentView);
//            make.width.mas_equalTo(@5);
//        }];
    }
    return self;
}

- (void)setMainStartHomeTableViewCellInfo:(Erc20Token *)info {
//    [self.coinImg setImage:[UIImage iconWithInfo:IconInfoMake(info, 30, [UIColor blueColor])]];
    [self.coinImg sd_setImageWithURL:[NSURL URLWithString:info.image] placeholderImage:[UIImage imageNamed:@""]];
    [self.symbolLbl setText:info.symbol];
    BigNumber *balance = info.balance;
    [self.balenceLbl setBalance:balance];
    NSString *ethers = [Payment formatEther:balance];
    CachedDataStore *dataStore = [CachedDataStore sharedCachedDataStoreWithKey:CACHEKEY_APP_DATA];
    NSString *unit = [dataStore stringForKey:CACHEKEY_APP_DATA_UNIT];
    BOOL isDollar = [unit isEqualToString:UNIT_DOLLAR];
    [self.assetLbl setText:[NSString stringWithFormat:@"%@ %.2f",unit,ethers.doubleValue * (isDollar?info.price.doubleValue:info.cnyPrice.doubleValue)]];
}

#pragma mark - Init
//- (UIView *)leftView {
//    if (!_leftView) {
//        _leftView = [UIView new];
//        _leftView.backgroundColor = [UIColor commonGreenColor];
//    }
//    return _leftView;
//}

- (UIImageView *)coinImg {
    if (!_coinImg) {
        _coinImg = [UIImageView new];
    }
    return _coinImg;
}

- (BalanceLabel *)balenceLbl {
    if (!_balenceLbl) {
        _balenceLbl = [BalanceLabel balanceLabelWithFrame:CGRectMake(0, 0, 80, 20) fontSize:15.0f color:BalanceLabelColorStatus alignment:BalanceLabelAlignmentAlignDecimal];
    }
    return _balenceLbl;
}

- (UILabel *)assetLbl {
    if (!_assetLbl) {
        _assetLbl = [UILabel new];
        _assetLbl.textColor = [UIColor commonWhiteColor];
        _assetLbl.font = [UIFont systemFontOfSize:15.0f];
    }
    return _assetLbl;
}

- (UILabel *)symbolLbl {
    if (!_symbolLbl) {
        _symbolLbl = [UILabel new];
        _symbolLbl.textColor = [UIColor commonWhiteColor];
        _symbolLbl.font = [UIFont systemFontOfSize:18.0f];
    }
    return _symbolLbl;
}

//- (UIView *)rightView {
//    if (!_rightView) {
//        _rightView = [UIView new];
//        _rightView.backgroundColor = [UIColor commonRedColor];
//    }
//    return _rightView;
//}
@end
