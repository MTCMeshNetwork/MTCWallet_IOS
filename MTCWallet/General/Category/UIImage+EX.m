//
//  UIImage+EX.m
//  ZSEthersWallet
//
//  Created by L on 2018/1/9.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "UIImage+EX.h"

@implementation UIImage (EX)

/**
 * 创建纯色的图片，用来做背景
 */
+ (UIImage *)at_imageWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, 0, [UIScreen mainScreen].scale);
    [color set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *ColorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return ColorImg;
}

@end
