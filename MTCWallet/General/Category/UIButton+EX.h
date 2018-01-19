//
//  UIButton+EX.h
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/3.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (EX)

@property (strong, nonatomic) UIColor *titleColor;
@property (strong, nonatomic) UIColor *highlightedTitleColor;
@property (strong, nonatomic) UIColor *selectedTitleColor;

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *highlightedTitle;
@property (copy, nonatomic) NSString *selectedTitle;

@property (copy, nonatomic) NSString *image;
@property (copy, nonatomic) NSString *highlightedImage;
@property (copy, nonatomic) NSString *selectedImage;

@property (copy, nonatomic) NSString *bgImage;
@property (copy, nonatomic) NSString *highlightedBgImage;
@property (copy, nonatomic) NSString *selectedBgImage;

- (void)addTarget:(id)target action:(SEL)action;

+ (UIButton *)buttonWithtitle:(NSString *)title
                   titleColor:(UIColor *)titleColor
                     fontSize:(CGFloat)size
              BackgroundColor:(UIColor *)backgroundColor
                        targe:(id)targe
                       action:(SEL)action;

+ (UIButton *)buttonWithImage:(NSString *)image
                        targe:(id)targe
                       action:(SEL)action;

@end
