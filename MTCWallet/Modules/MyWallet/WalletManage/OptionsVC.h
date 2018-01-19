//
//  OptionsVC.h
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/5.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "ConfigController.h"

@interface OptionsVC : UIViewController

+ (instancetype)optionWithHeading: (NSString*)heading
                       subheading: (NSString*)subheading
                         messages: (NSArray<NSString*>*)messages
                          options: (NSArray<NSString*>*)options;


@property (nonatomic, readonly) NSString *heading;
@property (nonatomic, readonly) NSString *subheading;
@property (nonatomic, readonly) NSArray *messages;
@property (nonatomic, readonly) NSArray *options;

@property (nonatomic, copy) void (^onOption)(OptionsVC *, NSUInteger index);

@end
