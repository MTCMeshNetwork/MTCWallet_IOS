//
//  ZSCustomButton.m
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/3.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "ZSCustomButton.h"

@interface ZSCustomButton ()

@end

@implementation ZSCustomButton

#pragma mark Layout Subview
- (void)layoutSubviews{
    [super layoutSubviews];
    
    // 1. 得到imageView和titleLabel的宽、高
    CGFloat imageWith = self.imageView.frame.size.width;
    CGFloat imageHeight = self.imageView.frame.size.height;
    
    CGFloat labelWidth = 0.0;
    CGFloat labelHeight = 0.0;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        // 由于iOS8中titleLabel的size为0，用下面的这种设置
        labelWidth = self.titleLabel.intrinsicContentSize.width;
        labelHeight = self.titleLabel.intrinsicContentSize.height;
    } else {
        labelWidth = self.titleLabel.frame.size.width;
        labelHeight = self.titleLabel.frame.size.height;
    }
    
    // 2. 声明全局的imageEdgeInsets和labelEdgeInsets
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;
    
    //根据YSLCustomButtonType和ysl_spacing得到imageEdgeInsets和labelEdgeInsets的值
    switch (self.zs_buttonType) {
        case ZSCustomButtonImageTop:{
            imageEdgeInsets = UIEdgeInsetsMake(-labelHeight - self.zs_spacing , 0, 0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight - self.zs_spacing , 0);
            break;
        }
        case ZSCustomButtonImageLeft:{
            imageEdgeInsets = UIEdgeInsetsMake(0, -self.zs_spacing , 0, self.zs_spacing );
            labelEdgeInsets = UIEdgeInsetsMake(0, self.zs_spacing , 0, -self.zs_spacing );
            break;
        }
        case ZSCustomButtonImageBottom:{
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight - self.zs_spacing , -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(-imageHeight - self.zs_spacing , -imageWith, 0, 0);
            break;
        }
        case ZSCustomButtonImageRight:{
            imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth + self.zs_spacing , 0, -labelWidth - self.zs_spacing );
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith - self.zs_spacing , 0, imageWith + self.zs_spacing );
            break;
        }
        default:
            break;
    }
    
    
    // 4. 赋值
    self.titleEdgeInsets = labelEdgeInsets;
    self.imageEdgeInsets = imageEdgeInsets;
}


#pragma mark lazy loading
- (CGFloat)zs_spacing{
    if (!_zs_spacing) {
        _zs_spacing = 5;
    }
    return _zs_spacing;
}



+ (ZSCustomButton *)buttonWithType:(ZSCustomButtonType)type
                             title:(NSString *)title
                        titleColor:(UIColor *)titleColor
                          fontSize:(CGFloat)size
                         imageName:(NSString *)imageName
                   backgroundColor:(UIColor *)backgroundColor
                             targe:(id)targe
                            action:(SEL)action
{
    ZSCustomButton *button = [[ZSCustomButton alloc] init];
    button.zs_buttonType = type;
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:size]];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setBackgroundColor:backgroundColor];
    [button addTarget:targe action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}
@end
