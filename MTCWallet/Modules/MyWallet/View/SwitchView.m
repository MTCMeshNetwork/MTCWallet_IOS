//
//  SwitchView.m
//  ZSEthersWallet
//
//  Created by L on 2018/1/7.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "SwitchView.h"

@interface SwitchView ()

@property (nonatomic, strong) UIImageView *imgView;
@end

@implementation SwitchView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
//        [self setShowLineType:ShowLineType_Top];
        
        [self addSubview:self.titleLb];
        [self addSubview:self.detailLb];
        [self addSubview:self.imgView];
        
        [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.centerY.equalTo(self);
        }];
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-15);
            make.centerY.equalTo(self);
        }];
        
        [self.detailLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.imgView.mas_left).offset(-15);
            make.centerY.equalTo(self);
        }];
    }
    return self;
}

- (void)setSwitchViewTitle:(NSString *)title detail:(NSString *)str {
    self.titleLb.text = title;
    self.detailLb.text = str;
}

#pragma mark - Init
- (UILabel *)titleLb {
    if (!_titleLb) {
        _titleLb = [UILabel new];
        _titleLb.font = [UIFont systemFontOfSize:16.0f];
        _titleLb.textColor = [UIColor commonlightGrayTextColor];
    }
    return _titleLb;
}

- (UILabel *)detailLb {
    if (!_detailLb) {
        _detailLb = [UILabel new];
        _detailLb.font = [UIFont systemFontOfSize:16.0f];
        _detailLb.textColor = [UIColor commonlightGrayTextColor];
    }
    return _detailLb;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [UIImageView new];
        _imgView.image = [UIImage imageNamed:@"icon_r_gray_arrow"];
    }
    return _imgView;
}
@end
