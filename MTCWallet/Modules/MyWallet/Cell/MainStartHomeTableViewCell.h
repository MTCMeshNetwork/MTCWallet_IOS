//
//  MainStartHomeTableViewCell.h
//  ZSEthersWallet
//
//  Created by thomasho on 2017/12/29.
//  Copyright © 2017年 lkl. All rights reserved.
//

#import "MGSwipeTableCell.h"

@interface MainStartHomeTableViewCell : MGSwipeTableCell

- (void)setMainStartHomeTableViewCellInfo:(Erc20Token *)info defaultPrice:(float)etherPrice;

@end
