//
//  IconInfo.m
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/5.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "IconInfo.h"

@implementation IconInfo

- (instancetype)initWithText:(NSString *)text size:(NSInteger)size color:(UIColor *)color {
    if (self = [super init]) {
        self.text = text;
        self.size = size;
        self.color = color;
    }
    return self;
}

+ (instancetype)iconInfoWithText:(NSString *)text size:(NSInteger)size color:(UIColor *)color {
    return [[IconInfo alloc] initWithText:text size:size color:color];
}

@end
