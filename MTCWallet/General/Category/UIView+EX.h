//
//  UIView+EX.h
//  ZSEthersWallet
//
//  Created by thomasho on 2017/12/28.
//  Copyright © 2017年 lkl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (EX)

// 标识，类名string
+ (NSString *)at_identifier;

@property (nonatomic, readonly) CGSize size;

@property (nonatomic, assign) float left;
@property (nonatomic, assign) float right;
@property (nonatomic, assign) float top;
@property (nonatomic, assign) float bottom;

@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;

@end
