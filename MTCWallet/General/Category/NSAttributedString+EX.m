//
//  NSAttributedString+EX.m
//  ZSEthersWallet
//
//  Created by thomasho on 2017/12/28.
//  Copyright © 2016年 yinquan. All rights reserved.
//

#import "NSAttributedString+EX.h"

@implementation NSAttributedString (EX)
/**
 *  改变一个字符串指定字符的样式（颜色，大小等）
 *
 *  @param changePart    根据数据会变化的部分
 *  @param unChangePart  固定不变的部分
 *  @param changeColor 固定不变部分需要改成的颜色
 *  @param changeFont  固定不变部分需要改成的大小
 *
 *  @return 经过改变的 NSAttributedString
 */
+ (NSAttributedString *)getAttributWithString:(NSString *)allStr UnChangePart:(NSString *)unChangePart changePart:(NSString *)changePart changeColor:(UIColor *)changeColor changeFont:(UIFont *)changeFont{
    
    NSRange changePartRange = [allStr rangeOfString:changePart];
    NSMutableAttributedString *allAttStr = [[NSMutableAttributedString alloc] initWithString:allStr];
    if (changeColor) {
        [allAttStr addAttribute:NSForegroundColorAttributeName value:changeColor range:changePartRange];
    }
    if (changeFont) {
        [allAttStr addAttribute:NSFontAttributeName value:changeFont range:changePartRange];
    }
    return allAttStr;
}

@end
