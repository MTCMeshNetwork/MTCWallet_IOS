//
//  UIViewController+ShowAlert.m
//  ZSEthersWallet
//
//  Created by L on 2018/1/9.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "UIViewController+ShowAlert.h"

@implementation UIViewController (ShowAlert)

- (UIViewController *)topViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

- (void)showAlertWithTitle:(NSString *)title Message:(NSString *)msg clicked:(void(^)(NSString *))clicked {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"输入交易密码",nil);
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *passwordfiled = alertController.textFields[0];
        if (clicked) {
            clicked(passwordfiled.text);
        }
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showAlertMessage:(NSString *)msg cancelTitle:(NSString *)cancelTitle cancelClicked:(void(^)(void))cancelClicked confirmTitle:(NSString *)confirmTitle confirmClicked:(void(^)(void))confirmClicked {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (cancelClicked) {
            cancelClicked();
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (confirmClicked) {
            confirmClicked();
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
