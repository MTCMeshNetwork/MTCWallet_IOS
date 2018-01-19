//
//  UIImage+EX.h
//  ZSEthersWallet
//
//  Created by L on 2018/1/9.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (EX)

/**
 * 创建纯色的图片，用来做背景
 */
+ (UIImage *)at_imageWithColor:(UIColor *)color size:(CGSize)size;

@end
