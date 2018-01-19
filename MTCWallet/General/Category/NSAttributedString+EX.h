//
//  NSAttributedString+EX.h
//  ZSEthersWallet
//
//  Created by thomasho on 2017/12/28.
//  Copyright © 2016年 yinquan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (EX)
/**
 *  改变一个字符串指定字符的样式（颜色，大小等）
 *
 *  @param changePart    根据数据会变化的部分
 *  @param unChangePart  固定不变的部分
 *  @param unChangeColor 固定不变部分需要改成的颜色
 *  @param unChangeFont  固定不变部分需要改成的大小
 *
 *  @return 经过改变的 NSAttributedString
 */

+ (NSAttributedString *)getAttributWithString:(NSString *)allStr UnChangePart:(NSString *)unChangePart changePart:(NSString *)changePart changeColor:(UIColor *)changeColor changeFont:(UIFont *)changeFont;

@end
