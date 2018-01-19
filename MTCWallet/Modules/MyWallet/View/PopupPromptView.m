//
//  PopupPromptView.m
//  ZSEthersWallet
//
//  Created by L on 2018/1/7.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "PopupPromptView.h"

@interface PopupPromptView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLb;
@property (nonatomic, strong) UILabel *promptLb;
@property (nonatomic, strong) UIButton *importButton, *deleteButton, *cancelButton;

@end

@implementation PopupPromptView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self configElements];
    }
    return self;
}

- (void)promptButtonClick:(UIButton *)sender {
    [self removeFromSuperview];
    switch (sender.tag) {
        case 1:
        case 2:
            if (self.block) {
                self.block(sender.tag);
            }
            break;
            
//        case 3:
//        {
//            [self removeFromSuperview];
//            break;
//        }
            
        default:
            break;
    }
    
}

- (void)showWithAnimation:(BOOL)animation {
    
    self.frame = ScreenBounds;
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    if (animation) {
        [self.contentView addAnimationForView];
    }
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
}

- (void)dismiss {
    [self removeFromSuperview];
}

- (void)configElements {
    
    self.contentView = [UIView new];
    [self addSubview:self.contentView];
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.left.equalTo(self).offset(30);
        make.right.equalTo(self).offset(-30);
        make.height.mas_equalTo(@260);
    }];
    
    self.titleLb = [UILabel new];
    [self.contentView addSubview:self.titleLb];
    self.titleLb.text = NSLocalizedString(@"删除提示！",nil);
    self.titleLb.textColor = [UIColor commonRedColor];
    self.titleLb.font = [UIFont systemFontOfSize:16.0f];
    self.titleLb.textAlignment = NSTextAlignmentCenter;
    [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(15);
    }];
    
    self.promptLb = [UILabel new];
    [self.contentView addSubview:self.promptLb];
    self.promptLb.textColor = [UIColor commonTextColor];
    self.promptLb.font = [UIFont systemFontOfSize:18.0f];
    [self.promptLb setAttributedText:[NSAttributedString getAttributWithString:NSLocalizedString(@"钱包删除后，将无法撤销操作，请确保已备份钱包私钥！",nil) UnChangePart:@"" changePart:NSLocalizedString(@"将无法撤销操作",nil) changeColor:[UIColor commonRedColor] changeFont:[UIFont systemFontOfSize:18.0f]]];
    self.promptLb.numberOfLines = 0;
    self.promptLb.textAlignment = NSTextAlignmentCenter;
    [self.promptLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.titleLb.mas_bottom).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    
    self.importButton = [UIButton buttonWithtitle:NSLocalizedString(@"备份/导出钱包",nil) titleColor:[UIColor whiteColor] fontSize:16.0f BackgroundColor:[UIColor commonGreenColor] targe:self action:@selector(promptButtonClick:)];
    [self.contentView addSubview:self.importButton];
    [self.importButton setTag:0x01];
    
    self.deleteButton = [UIButton buttonWithtitle:NSLocalizedString(@"确认删除",nil) titleColor:[UIColor whiteColor] fontSize:16.0f BackgroundColor:[UIColor commonRedColor] targe:self action:@selector(promptButtonClick:)];
    [self.contentView addSubview:self.deleteButton];
    [self.deleteButton setTag:0x02];
    
    self.cancelButton = [UIButton buttonWithtitle:NSLocalizedString(@"取消",nil) titleColor:[UIColor commonTextColor] fontSize:16.0f BackgroundColor:[UIColor whiteColor] targe:self action:@selector(promptButtonClick:)];
    [self.cancelButton.layer setBorderColor:[UIColor commonLightGrayTextColor].CGColor];
    [self.cancelButton.layer setBorderWidth:1.0f];
    [self.contentView addSubview:self.cancelButton];
    [self.cancelButton setTag:0x03];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.centerX.equalTo(self.contentView);
        make.height.mas_equalTo(@45);
        make.bottom.equalTo(self.contentView).offset(-15);
    }];
    
    //等间距布局
    [@[self.importButton, self.deleteButton] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:10 leadSpacing:15 tailSpacing:15];
    
    [@[self.importButton, self.deleteButton] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.cancelButton.mas_top).offset(-10);
        make.width.mas_equalTo(self.importButton.mas_width);
        make.height.mas_equalTo(@45);
    }];
}



@end
