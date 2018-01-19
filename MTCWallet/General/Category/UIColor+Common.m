//
//  UIColor+Common.m
//  ZSEthersWallet
//
//  Created by thomasho on 2017/12/28.
//  Copyright © 2016年 lkl. All rights reserved.
//

#import "UIColor+Common.h"

@implementation UIColor (Common)

+ (UIColor*) mainThemeColor {
    return [UIColor colorWithHexString:@"7BCCC8"];
}

//背景颜色
+ (UIColor *)commonBackgroundColor {
    return [UIColor colorWithHexString:@"292c36"];
}

//cell颜色
+ (UIColor *)commonCellcolor {
    return [UIColor colorWithHexString:@"3f4046"];
}

// 乳白色
+ (UIColor *)commonWhiteColor {
    return [UIColor colorWithHexString:@"c6c4c4"];
}

+ (UIColor *)commonGreenColor {
    return [UIColor colorWithHexString:@"21c95c"];
}

// 粉红
+ (UIColor *)commonPinkColor {
    return [UIColor colorWithHexString:@"b6326f"];
}

//自定义红色
+ (UIColor *)commonRedColor {
    return [UIColor colorWithHexString:@"dd3155"];
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
//橘黄
+ (UIColor *)commonOrangeTextColor {
    return [UIColor colorWithHexString:@"ed6f2d"];
}

@end
