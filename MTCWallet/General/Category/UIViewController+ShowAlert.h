//
//  UIViewController+ShowAlert.h
//  ZSEthersWallet
//
//  Created by L on 2018/1/9.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ShowAlert)

- (UIViewController *)topViewController;

- (void)showAlertWithTitle:(NSString *)title Message:(NSString *)msg clicked:(void(^)(NSString *))clicked;

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)msg cancelTitle:(NSString *)cancelTitle cancelClicked:(void(^)(void))cancelClicked confirmTitle:(NSString *)confirmTitle confirmClicked:(void(^)(void))confirmClicked;
@end
