//
//  ZSCreateQRCode.h
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/2.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSCreateQRCode : NSObject

/**
 *根据传入的字符串来生成相应的二维码
 *@param   string     传入的字符串
 *@param   vc         调用方法时当前的Viewcontroller
 *@return  UIImage(二维码)
 */
+ (UIImage *)createQRCodeWithString:(NSString *)string ViewController:(UIViewController *)vc;


@end
