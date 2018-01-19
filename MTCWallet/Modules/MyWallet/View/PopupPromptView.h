//
//  PopupPromptView.h
//  ZSEthersWallet
//
//  Created by L on 2018/1/7.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^deleteBlock)(NSInteger index);

@interface PopupPromptView : UIView

- (void)showWithAnimation:(BOOL)animation;
- (void)dismiss;

@property (nonatomic, copy) deleteBlock block;
@end
