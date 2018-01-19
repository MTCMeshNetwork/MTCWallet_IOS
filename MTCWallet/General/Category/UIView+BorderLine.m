//
//  UIView+BorderLine.m
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/4.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "UIView+BorderLine.h"

static const NSInteger kBaseLineTag = 0x9864;
static const NSInteger kLeftLineTag = kBaseLineTag;
static const NSInteger kTopLineTag = kBaseLineTag + 1;
static const NSInteger kRightLineTag = kBaseLineTag + 2;
static const NSInteger kBottomLineTag = kBaseLineTag + 3;

@implementation UIView (BorderLine)

- (void)setShowLineType:(ShowLineType)type
{
    NSInteger kLineTag;
    switch (type) {
        case ShowLineType_Top:
            kLineTag = kTopLineTag;
            break;
            
        case ShowLineType_Left:
            kLineTag = kLeftLineTag;
            break;
            
        case ShowLineType_Bottom:
            kLineTag = kBottomLineTag;
            break;
            
        case ShowLineType_Right:
            kLineTag = kRightLineTag;
            break;
            
        default:
            break;
    }
    
    UIView *lineView;
    NSArray *subviews = [self subviews];
    for (UIView *subview in subviews){
        if (subview.superview == self && kLineTag == subview.tag ) {
            lineView = subview;
            break;
        }
    }

    if (lineView){
        return;
    }
    
    lineView = [[UIView alloc] init];
    [self addSubview:lineView];
    [lineView setTag:kLineTag];
    [lineView setBackgroundColor:[UIColor commonBorderLineColor]];
    
    switch (type) {
        case ShowLineType_Top:
        {
            [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.equalTo(self);
                make.top.equalTo(self);
                make.height.mas_equalTo(@0.5);
            }];
            break;
        }
            
        case ShowLineType_Left:
        {
            [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
                make.top.bottom.equalTo(self);
                make.width.mas_equalTo(@0.5);
            }];
            break;
        }
            
        case ShowLineType_Bottom:
        {
            [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.equalTo(self);
                make.bottom.equalTo(self);
                make.height.mas_equalTo(@0.5);
            }];
            break;
        }
            
        case ShowLineType_Right:
        {
            [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self);
                make.top.bottom.equalTo(self);
                make.width.mas_equalTo(@0.5);
            }];
            break;
        }
            
        default:
            break;
    }
}

@end
