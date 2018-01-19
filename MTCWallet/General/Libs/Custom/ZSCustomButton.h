//
//  ZSCustomButton.h
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/3.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger,ZSCustomButtonType) {
    ZSCustomButtonImageTop    = 0 , //图片在上边
    ZSCustomButtonImageLeft   = 1 , //图片在左边
    ZSCustomButtonImageBottom = 2 , //图片在下边
    ZSCustomButtonImageRight  = 3   //图片在右边
};

@interface ZSCustomButton : UIButton

/** 图片和文字间距 默认10px*/
@property (nonatomic , assign) CGFloat zs_spacing;

/** 按钮类型 默认YSLCustomButtonImageTop 图片在上边*/
@property (nonatomic , assign) ZSCustomButtonType zs_buttonType;

+ (ZSCustomButton *)buttonWithType:(ZSCustomButtonType)type
                             title:(NSString *)title
                        titleColor:(UIColor *)titleColor
                          fontSize:(CGFloat)size
                         imageName:(NSString *)imageName
                   backgroundColor:(UIColor *)backgroundColor
                             targe:(id)targe
                            action:(SEL)action;
@end
