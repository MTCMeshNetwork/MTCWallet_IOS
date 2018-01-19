//
//  OptionsVC.m
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/5.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "OptionsVC.h"
#import <Masonry/Masonry.h>
#import "BlockButton.h"
#import "Utilities.h"
#import "IconFont.h"
#import "UIImage+IconFont.h"
#import "UIColor+hex.h"
#import "WRNavigationBar.h"

@interface OptionsVC ()

@end

@implementation OptionsVC

+ (instancetype)optionWithHeading:(NSString *)heading
                       subheading:(NSString *)subheading
                         messages:(NSArray<NSString *> *)messages
                          options:(NSArray<NSString *> *)options {
    return [[OptionsVC alloc] initWithHeading:heading subheading:subheading messages:messages options:options];
}

- (instancetype)initWithHeading:(NSString *)heading
                     subheading:(NSString *)subheading
                       messages:(NSArray<NSString *> *)messages
                        options:(NSArray<NSString *> *)options {
    
    self = [super init];
    if (self) {
        _heading = heading;
        _subheading = subheading;
        _messages = [messages copy];
        _options = [options copy];
    }
    return self;
}

- (UIButton*)addButton: (NSString*)text image:(UIImage *)image action: (void (^)(UIButton*))action {
    BlockButton *button = [BlockButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:FONT_NORMAL size:20.0f];
    [button handleControlEvent:UIControlEventTouchUpInside withBlock:action];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHex:0x98beef alpha:0.5f] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor colorWithHex:0x98beef alpha:0.3f] forState:UIControlStateDisabled];
    [self.view addSubview:button];
    
    [button setFrame:CGRectMake(0, 0, 170, 130)];
    
    UIView *upView = button.imageView;
    UIView *downView = button.titleLabel;
    button.titleEdgeInsets = UIEdgeInsetsMake(upView.frame.size.height+20, -upView.frame.size.width, 0,0);
    button.imageEdgeInsets = UIEdgeInsetsMake(-downView.frame.size.height, 0, 0, -downView.frame.size.width);
    
    return button;
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor  = COLOR_BACKGROUND;
    
    [self wr_setNavBarTintColor:[UIColor whiteColor]];
    [self wr_setNavBarTitleColor:[UIColor whiteColor]];
    [self wr_setNavBarBarTintColor:COLOR_GREEN];
    [self wr_setNavBarShadowImageHidden:YES];
    
    UIView *titleView = [[UIView alloc] init];
    [titleView setBackgroundColor:COLOR_GREEN];
    [self.view addSubview:titleView];
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@150);
    }];
    
    UILabel *lbl = [[UILabel alloc] init];
    lbl.text = _heading;
    lbl.textColor = [UIColor whiteColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:lbl];
    [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(titleView);
    }];
    
    __weak OptionsVC *weakSelf = self;
    
    void (^tapButton)(UIButton *button)  = ^(UIButton *button) {
        if (weakSelf.onOption) {
            weakSelf.onOption(weakSelf, button.tag);
        }
    };
    
    NSUInteger index = 0;
    for (NSString *option in _options) {
        UIImage *image = [UIImage iconWithInfo:IconInfoMake(_messages[index], 40, [UIColor whiteColor])];
        UIButton *button = [self addButton:option image:image action:tapButton];
        [button setBackgroundColor:index%2?COLOR_GREEN:COLOR_PINK];
        button.tag = index++;
        [self.view addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleView).offset(60+index*170);
            make.centerX.equalTo(titleView);
            make.width.equalTo(@170);
            make.height.equalTo(@130);
        }];
    }
}

@end
