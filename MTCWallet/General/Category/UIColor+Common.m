//
//  UIColor+Common.m
//  ZSEthersWallet
//
//  Created by thomasho on 2017/12/28.
//  Copyright © 2016年 lkl. All rights reserved.
//

#import "UIColor+Common.h"

@implementation UIColor (Common)

+ (UIColor *)mainThemeColor {
    return [UIColor colorWithHexString:@"272a36"];
}

//背景颜色
+ (UIColor *)commonBackgroundColor {
    return [UIColor colorWithHexString:@"272a36"];
}

//cell颜色
+ (UIColor *)commonCellcolor {
    //    return [UIColor colorWithHexString:@"52555e"];
    return [UIColor colorWithHexString:@"30333d"];
}

// 白色
+ (UIColor *)commonWhiteColor {
    return [UIColor colorWithHexString:@"ffffff"];
}

+ (UIColor *)commonGreenColor {
    return [UIColor colorWithHexString:@"2ea84b"];
}

// 粉红
+ (UIColor *)commonPinkColor {
    return [UIColor colorWithHexString:@"dd3155"];
}

//自定义红色
+ (UIColor *)commonRedColor {
    return [UIColor colorWithHexString:@"c03838"];
}

//自定义蓝色
+ (UIColor *)commonBlueColor {
    return [UIColor colorWithHexString:@"368af2"];
}

//灰色
+ (UIColor *)commonBorderLineColor {
    return [UIColor colorWithHexString:@"737374"];
}

//常规字体颜色
+ (UIColor *)commonTextColor {
    return [UIColor colorWithHexString:@"333333"];
}

//常规字体颜色
+ (UIColor *)commonLightGrayTextColor {
    return [UIColor colorWithHexString:@"e4e4e4"];
}

//深灰
+ (UIColor *)commonDarkGrayTextColor {
    return [UIColor colorWithHexString:@"666666"];
}

//浅灰
+ (UIColor *)commonlightGrayTextColor {
    return [UIColor colorWithHexString:@"999999"];
}

//橘黄
+ (UIColor *)commonOrangeTextColor {
    return [UIColor colorWithHexString:@"ff6000"];
}

+ (UIColor *)commonAccountsCellcolor {
    return [UIColor colorWithHexString:@"1f1f22"];
}

@end
