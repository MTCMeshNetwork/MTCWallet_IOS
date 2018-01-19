//
//  ExportVC.m
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/7.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "ExportWalletVC.h"
#import "Utilities.h"
#import "ZSCreateQRCode.h"
#import "BlockButton.h"
#import "WRNavigationBar.h"

@interface ExportWalletVC ()

//@property (nonatomic, strong) NSString *content;
@property (nonatomic, assign) ExportType exportType;

- (void)loadTitle:(NSString *)title subTitle:(NSString *)subTitle content:(NSString *)content buttonTitle:(NSString *)buttonTitle;

@end

@implementation ExportWalletVC

+ (ExportWalletVC *)export:(NSString *)content withType:(ExportType)type {
    ExportWalletVC *vc = [[ExportWalletVC alloc] initWithStyle:UITableViewStylePlain];
    vc.exportType = type;
    switch (type) {
        case ExportTypeKeyStore:
            vc.title = NSLocalizedString(@"导出Keystore", nil);
            [vc loadTitle:NSLocalizedString(@"重要提示：1.请离线保存；2.请勿使用网络传输；3.二维码禁止保存、截图和拍照，确保在四周无人和摄像头环境下扫码。", nil)
                 subTitle:nil
                  content:content
              buttonTitle:NSLocalizedString(@"复制Keystore", nil)];
            break;
        case ExportTypeMnmenic:
            vc.title = NSLocalizedString(@"备份助记词", nil);
            [vc loadTitle:NSLocalizedString(@"抄写下你的钱包助记词", nil)
                 subTitle:NSLocalizedString(@"助记词用于恢复钱包或重置钱包密码，将它准确地抄写到纸上，并存放在只有你知道的安全的地方。", nil)
                  content:content
              buttonTitle:NSLocalizedString(@"下一步", nil)];
            break;
        case ExportTypeMnmenicConfirm:
            vc.title = NSLocalizedString(@"备份助记词", nil);
            [vc loadTitle:NSLocalizedString(@"确认你的钱包助记词", nil)
                 subTitle:NSLocalizedString(@"请按顺序点击助记词，以确认你的备份正确。", nil)
                  content:content
              buttonTitle:NSLocalizedString(@"确认", nil)];
            break;
        case ExportTypePrivateKey:
            vc.title = NSLocalizedString(@"导出明文私钥", nil);
            [vc loadTitle:NSLocalizedString(@"安全警告：私钥未经加密，导出存在风险，建议使用助记词和Keystore进行备份。", nil)
                 subTitle:nil
                  content:content
              buttonTitle:NSLocalizedString(@"复制明文私钥", nil)];
            break;
    }
    return vc;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor colorWithWhite:0x50/255. alpha:1];
    self.tableView.tableFooterView = [UIView new];
    
    [self wr_setNavBarTintColor:[UIColor whiteColor]];
    [self wr_setNavBarTitleColor:[UIColor whiteColor]];
    [self wr_setNavBarBarTintColor:[UIColor colorWithWhite:0x50/255.0 alpha:1]];
}

#pragma mark - **************** UI
- (UILabel *)addLabel:(NSString *)title color:(UIColor *)textColor inView:(UIView *)view {
    UILabel *lbl = [UILabel new];
    lbl.textColor = textColor;
    lbl.numberOfLines = 0;
    lbl.font = [UIFont systemFontOfSize:15];
    lbl.text = title;
    [view addSubview:lbl];
    return lbl;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (void)loadTitle:(NSString *)title subTitle:(NSString *)subTitle content:(NSString *)content buttonTitle:(NSString *)buttonTitle {
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 600)];
    contentView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = contentView;
    
    UILabel *lbl = [self addLabel:title color:COLOR_WARNING inView:contentView];
    if (_exportType == ExportTypeMnmenic ||_exportType == ExportTypeMnmenicConfirm) {
        lbl.textAlignment = NSTextAlignmentCenter;
    }
    [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(contentView).insets(UIEdgeInsetsMake(30, 20, 0, 20));
    }];
    
    if (subTitle.length) {
        UILabel *sublbl = [self addLabel:subTitle color:[UIColor blackColor] inView:contentView];
        [sublbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(lbl).insets(UIEdgeInsetsMake(30, 0, 0, 0));
        }];
        lbl = sublbl;
    }
    
    UIView *bg = [UIView new];
    bg.backgroundColor = [UIColor colorWithWhite:0xf2/255. alpha:1];;
    [contentView addSubview:bg];
    
    UITextView *txt = [UITextView new];
    txt.editable = NO;
    txt.scrollEnabled = NO;
    txt.textColor = [UIColor blackColor];
    txt.font = [UIFont systemFontOfSize:15];
    txt.backgroundColor  = [UIColor clearColor];
    [contentView addSubview:txt];
    
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbl.mas_bottom).offset(30);
        make.left.right.equalTo(lbl);
        make.height.equalTo(txt).offset(40);
    }];
    
    [txt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bg);
        make.left.right.equalTo(lbl);
    }];
    UIView *optionView = nil;
    if (_exportType == ExportTypeKeyStore) {
        UIImageView *iv = [[UIImageView alloc] init];
        [contentView addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bg.mas_bottom).offset(30);
            make.width.height.equalTo(@200);
            make.centerX.equalTo(bg);
        }];
        optionView = iv;
            txt.text = content;
            [iv setImage:[ZSCreateQRCode createQRCodeWithString:txt.text ViewController:self]];
    }else if(_exportType == ExportTypeMnmenicConfirm) {
        void (^tapButton)(UIButton *button)  = ^(UIButton *button) {
            if (!button.isSelected) {
                [button setSelected:YES];
                [button setBackgroundColor:[UIColor colorWithHexString:@"d7d7d7"]];
                [bg.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                if(txt.text.length)txt.text = [NSString stringWithFormat:@"%@ %@",txt.text,button.currentTitle];
                else txt.text = button.currentTitle;
//                [self mnmenics:[txt.text componentsSeparatedByString:@" "] inView:bg onTap:nil];
            }
        };
        NSArray *orderMnmenics = [content componentsSeparatedByString:@" "];
        orderMnmenics = [orderMnmenics sortedArrayUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
            int seed = arc4random_uniform(2);
            if (seed) {
                return [str1 compare:str2];
            } else {
                return [str2 compare:str1];
            }
        }];
        optionView = [self mnmenics:orderMnmenics inView:contentView onTap:tapButton];
        [optionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bg.mas_bottom).offset(30);
            make.centerX.equalTo(bg);
            make.left.right.equalTo(bg);
        }];
    }else {
        txt.text = content;
        optionView = [UIView new];
        [contentView addSubview:optionView];
        [optionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bg.mas_bottom).offset(30);
            make.centerX.left.right.equalTo(bg);
            make.height.equalTo(@0);
        }];
    }
    
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor colorWithWhite:0x50/255. alpha:1];
    [contentView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(optionView.mas_bottom).offset(20);
        make.left.right.bottom.equalTo(contentView);
    }];
    
    BlockButton *copybutton = [BlockButton buttonWithType:UIButtonTypeCustom];
    [copybutton setTitle:buttonTitle forState:UIControlStateNormal];
    copybutton.layer.cornerRadius = 5;
    [copybutton setBackgroundColor:COLOR_GREEN];
    [contentView addSubview:copybutton];
    [copybutton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(bgView).insets(UIEdgeInsetsMake(20, 30, 0, 30));
        make.height.equalTo(@50);
    }];
    
    lbl = [self addLabel:@" " color:[UIColor clearColor] inView:contentView];
    [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(bgView);
        make.top.equalTo(copybutton.mas_bottom);
        make.height.equalTo(@20);
    }];
    
    __weak typeof(self) weakSelf = self;
    [copybutton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        switch (weakSelf.exportType) {
            case ExportTypeKeyStore:
                [[UIPasteboard generalPasteboard] setString:txt.text];
                showMessage(showTypeSuccess, NSLocalizedString(@"已复制到剪贴板", nil));
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                break;
            case ExportTypeMnmenic:
                [weakSelf.navigationController pushViewController:[ExportWalletVC export:content withType:ExportTypeMnmenicConfirm] animated:YES];
                break;
            case ExportTypePrivateKey:
                [[UIPasteboard generalPasteboard] setString:txt.text];
                showMessage(showTypeSuccess, NSLocalizedString(@"已复制到剪贴板", nil));
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                break;
            case ExportTypeMnmenicConfirm:
                if ([txt.text isEqualToString:content]) {
                    showMessage(showTypeSuccess, NSLocalizedString(@"助记词验证成功", nil));
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                }else{
                    showMessage(showTypeError, NSLocalizedString(@"助记词验证错误", nil));
                }
                break;
        }
    }];
    
}


- (CGSize)getSizeByString:(NSString*)string AndFontSize:(CGFloat)font{
    CGSize size=[string boundingRectWithSize:CGSizeMake(999, 25) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil].size;
    size.width += 5;
    return size;
}

- (UIButton *)addButton:(NSString *)title action:(void(^)(UIButton *))aciton {
    BlockButton *btn = [BlockButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    UIFont *font = [UIFont systemFontOfSize:15];
    btn.titleLabel.font = font;
    btn.layer.cornerRadius = 5;
    if(aciton)[btn handleControlEvent:UIControlEventTouchUpInside withBlock:aciton];
    return btn;
}


- (UIView *)mnmenics:(NSArray <NSString *> *)mnmenics inView:(UIView *)contentView onTap:(void(^)(UIButton *))aciton {
    
    UIView *hintView = [UIView new];
    [contentView addSubview:hintView];
    
    NSArray *distributeArr = [self distribute:mnmenics spacing:10 totalWidth:300];
    NSArray *array = nil;
    int count = 0;
    for (array in distributeArr) {
        for (BlockButton *btn in array) {
            [btn handleControlEvent:UIControlEventTouchUpInside withBlock:aciton];
            btn.tag = count++;
            [hintView addSubview:btn];
        }
        if (array.count == 1) {
            [array.firstObject mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@([distributeArr indexOfObject:array] * 30));
                make.height.equalTo(@25);
                make.left.equalTo(hintView).offset(10);
            }];
        }else {
            [array mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:10 leadSpacing:10 tailSpacing:10];
            [array mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@([distributeArr indexOfObject:array]*30));
                make.height.equalTo(@25);
            }];
        }
    }
    [hintView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(distributeArr.count*30));
    }];
    return hintView;
}

- (NSArray *)distribute:(NSArray *)words spacing:(CGFloat)space totalWidth:(CGFloat)total {
    CGFloat max = 0;
    NSMutableArray *totalArr = [NSMutableArray array];
    NSMutableArray *marr = [NSMutableArray array];
    for (NSString *word in words) {
        CGFloat wordWidth = [self getSizeByString:word AndFontSize:15].width;
        max += wordWidth+space;
        if (max <= total) {
            [marr addObject:[self addButton:word action:nil]];
        }else {
            [totalArr addObject:marr];
            marr = [NSMutableArray arrayWithObject:[self addButton:word action:nil]];
            max = wordWidth + space;
        }
    }
    if (marr.count) {
        [totalArr addObject:marr];
    }
    return [totalArr copy];
}

@end
