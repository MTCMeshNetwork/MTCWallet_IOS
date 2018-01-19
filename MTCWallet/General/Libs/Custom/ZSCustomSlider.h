//
//  ZSCustomSlider.h
//  ZSEthersWallet
//
//  Created by L on 2018/1/5.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSCustomSlider : UISlider

@property (nonatomic, strong) NSArray *colorArray;
@property (nonatomic, strong) NSArray *colorLocationArray;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end
