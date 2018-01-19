//
//  TipVC.h
//  CBPro
//
//  Created by thomasho on 2017/8/17.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ShowTipType) {
    ShowTipTypeBackup,
    ShowTipTypePassword,
    ShowTipTypeText,
};

typedef void(^TipsBlock)(id value,NSInteger index);

@interface TipVC : UIViewController

+ (instancetype)showTipType:(ShowTipType)type inController:(UIViewController *)viewController;
- (void)setTitle:(NSString *)message buttons:(NSArray<NSString *> *)buttons onCompletion:(TipsBlock)block;

@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSArray<NSString *> *buttons;
@property (nonatomic, copy) TipsBlock onCompletion;

@end
