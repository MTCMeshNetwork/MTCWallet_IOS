//
//  TipVC.m
//  CBPro
//
//  Created by thomasho on 2017/8/17.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "TipVC.h"
#import <Masonry/Masonry.h>
#import "BlockButton.h"
#import "AppDelegate.h"
#import "Utilities.h"

@interface TipVC ()

@property (nonatomic, assign) ShowTipType showTipType;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSArray<NSString *> *buttons;
@property (nonatomic, strong) id completionValue;

@end

@implementation TipVC

+ (instancetype)showTipType:(ShowTipType)type inController:(UIViewController *)vc; {
    TipVC *tipvc = [[TipVC alloc] init];
    tipvc.showTipType = type;
    tipvc.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    tipvc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    if (vc == nil) {
        // 获取不到最顶层
//        vc = [UIApplication sharedApplication].delegate.window.rootViewController;
        vc = [tipvc topViewController];
    }
    [vc presentViewController:tipvc animated:NO completion:nil];
    return tipvc;
}

- (void)setTitle:(NSString *)title buttons:(NSArray *)arr onCompletion:(TipsBlock)block {
    self.buttons = arr;
    self.message = title;
    self.onCompletion = block;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    switch (self.showTipType) {
        case ShowTipTypeBackup:
            [self animateTips:[self backupView]];
            break;
        
        case ShowTipTypePassword:
            [self animateTips:[self passwordView]];
            break;
            
        default:
            [self animateTips:[self tipView]];
            break;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noticeWillShowKeyboard:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noticeWillHideKeyboard:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIView *)tipView {
    UIView *contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:contentView];
    contentView.layer.masksToBounds = YES;
    contentView.layer.cornerRadius = 5.0f;
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).insets(UIEdgeInsetsMake(0, 30, 0, 30));
        make.centerY.equalTo(self.view);
        make.height.equalTo(@(200));
    }];
    
    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.text = _message;
    titleLbl.textColor = [UIColor colorWithWhite:0x66/255. alpha:1];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:titleLbl];
    [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(20);
        make.left.right.equalTo(contentView);
        make.height.equalTo(@50);
    }];
    __weak TipVC *weakSelf = self;
    void (^tapButton)(UIButton *button)  = ^(UIButton *button) {
        [weakSelf tipButtonClicked:button];
    };
    BlockButton *button = [BlockButton buttonWithType:UIButtonTypeCustom];
    [button handleControlEvent:UIControlEventTouchUpInside withBlock:tapButton];
    [contentView addSubview:button];
    [button setTitleColor:[UIColor colorWithWhite:0x66/255. alpha:1] forState:UIControlStateNormal];
    [button setTitle:NSLocalizedString(@"确认", nil) forState:UIControlStateNormal];
    button.layer.borderColor = [UIColor colorWithWhite:0xcc/255. alpha:1].CGColor;
    button.layer.borderWidth = 1;
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView).insets(UIEdgeInsetsMake(0, 20, 0, 20));
        make.height.equalTo(@44);
        make.bottom.equalTo(contentView).offset(-22);
    }];
    return contentView;
}

- (UIView *)passwordView {
    UIView *contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:contentView];
    contentView.layer.masksToBounds = YES;
    contentView.layer.cornerRadius = 5.0f;
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).insets(UIEdgeInsetsMake(0, 30, 0, 30));
        make.centerY.equalTo(self.view);
        make.height.equalTo(@180);
    }];
    
    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.text = NSLocalizedString(@"重要操作验证", nil);
    titleLbl.textColor = [UIColor mainThemeColor];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:titleLbl];
    [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(20);
        make.left.right.equalTo(contentView);
    }];
    
    UIView *tfBG = [UIView new];
    [contentView addSubview:tfBG];
    tfBG.layer.borderColor = [UIColor mainThemeColor].CGColor;
    tfBG.layer.borderWidth = 1;
    tfBG.layer.masksToBounds = YES;
    tfBG.layer.cornerRadius = 5.0f;
    [tfBG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(titleLbl).insets(UIEdgeInsetsMake(40, 15, 0, 15));
        make.height.equalTo(@45);
    }];
    
    UITextField *tf = [UITextField new];
    [contentView addSubview:tf];
    tf.placeholder = NSLocalizedString(@"输入钱包密码", nil);
    tf.keyboardType = UIKeyboardTypeNamePhonePad;
    tf.secureTextEntry = YES;
    [tf addTarget:self action:@selector(txtValueChange:) forControlEvents:UIControlEventEditingChanged];
    [tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(tfBG).insets(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
    
    BlockButton *button = [BlockButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSLocalizedString(@"确认", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor commonWhiteColor]];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    __weak TipVC *weakSelf = self;
    [button handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        if (tf.text.length) {
            [weakSelf tipButtonClicked:button];
        }else {
            showMessage(showTypeError, NSLocalizedString(@"请输入钱包密码", nil));
        }
    }];
//    [button addTarget:self action:@selector(tipButtonClicked:)];
//    button.layer.borderColor = [UIColor colorWithWhite:0xcc/255. alpha:1].CGColor;
//    button.layer.borderWidth = 1;
    button.backgroundColor = [UIColor mainThemeColor];
    button.tag = 1;
    [contentView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfBG.mas_bottom).offset(16);
        make.left.equalTo(contentView);
        make.width.equalTo(contentView).multipliedBy(0.5);
        make.bottom.equalTo(contentView);
    }];
    
    button = [BlockButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor commonWhiteColor]];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button addTarget:self action:@selector(tipButtonClicked:)];
//    button.layer.borderColor = [UIColor colorWithWhite:0xcc/255. alpha:1].CGColor;
//    button.layer.borderWidth = 1;
    button.backgroundColor = [UIColor commonRedColor];
    button.tag = 0;
    [contentView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfBG.mas_bottom).offset(16);
        make.right.equalTo(contentView);
        make.width.equalTo(contentView).multipliedBy(0.5);
        make.bottom.equalTo(contentView);
    }];
    
    return contentView;
}

- (UIView *)backupView {
    UIView *contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:contentView];
    contentView.layer.masksToBounds = YES;
    contentView.layer.cornerRadius = 5.0f;
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).insets(UIEdgeInsetsMake(0, 30, 0, 30));
        make.centerY.equalTo(self.view);
        make.height.equalTo(@(110 + _buttons.count*55));
    }];
    
    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.text = _message;
    titleLbl.textColor = [UIColor colorWithWhite:0x66/255. alpha:1];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:titleLbl];
    [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(contentView);
        make.height.equalTo(@55);
    }];
    
    UIView *line = [[UIView alloc] init];
    [line setBackgroundColor:[UIColor colorWithWhite:0xf5/255. alpha:1]];
    [contentView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(titleLbl);
        make.height.equalTo(@1);
        make.top.equalTo(titleLbl.mas_bottom);
    }];
    
    __weak TipVC *weakSelf = self;
    void (^tapButton)(UIButton *button)  = ^(UIButton *button) {
        [weakSelf tipButtonClicked:button];
    };
    
    NSUInteger index = 0;
    for (NSString *option in _buttons) {
        BlockButton *button = [BlockButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:[UIColor mainThemeColor] forState:UIControlStateNormal];
        [button handleControlEvent:UIControlEventTouchUpInside withBlock:tapButton];
        [contentView addSubview:button];
        button.tag = ++index;
        [button setTitle:option forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(contentView);
            make.height.equalTo(@54);
            make.top.equalTo(titleLbl).offset(1+55*index);
        }];
        
        line = [[UIView alloc] init];
        [line setBackgroundColor:[UIColor colorWithWhite:0xf5/255. alpha:1]];
        [contentView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(button);
            make.height.equalTo(@1);
            make.top.equalTo(button.mas_bottom);
        }];
    }
    
    BlockButton *button = [BlockButton buttonWithType:UIButtonTypeCustom];
    [button handleControlEvent:UIControlEventTouchUpInside withBlock:tapButton];
    [contentView addSubview:button];
    [button setTitleColor:[UIColor commonWhiteColor] forState:UIControlStateNormal];
    [button setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
//    button.layer.borderColor = [UIColor colorWithWhite:0xcc/255. alpha:1].CGColor;
//    button.layer.borderWidth = 1;
    button.backgroundColor = [UIColor mainThemeColor];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(contentView).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        make.height.equalTo(@55);
//        make.bottom.equalTo(contentView).offset(-22);
    }];
    return contentView;
}

- (void) animateTips:(UIView *)view
{
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.0f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [view.layer addAnimation:popAnimation forKey:nil];
    
}

- (void)txtValueChange:(UITextField *)tf {
    self.completionValue = tf.text;
}

- (IBAction)tipButtonClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    if (self.onCompletion) {
        self.onCompletion(self.completionValue,sender.tag);
    }
}

#pragma mark - UIScrollView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}


#pragma mark - Keyboard notifications

- (void)noticeWillShowKeyboard: (NSNotification*)note {
    CGRect newFrame = [[note.userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    NSTimeInterval duration = [[note.userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    
    UIView *contentView = self.view.subviews.firstObject;
    [contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).offset(- newFrame.size.height/2);
    }];
    void (^animations)(void) = ^() {
        [self.view setNeedsLayout];
    };
    
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:animations
                     completion:nil];
}

- (void)noticeWillHideKeyboard: (NSNotification*)note {
//    CGRect newFrame = [[note.userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    NSTimeInterval duration = [[note.userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    
    UIView *contentView = self.view.subviews.firstObject;
    [contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
    }];
    void (^animations)(void) = ^() {
        [self.view setNeedsLayout];
    };
    
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:animations
                     completion:nil];
}
@end
