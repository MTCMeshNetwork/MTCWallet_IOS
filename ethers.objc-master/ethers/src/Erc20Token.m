//
//  Erc20Token.m
//  ethers
//
//  Created by thomasho on 2018/1/18.
//  Copyright © 2018年 Ethers. All rights reserved.
//

#import "Erc20Token.h"
#import "ApiProvider.h"

@implementation Erc20Token

+ (Erc20Token *)erc20Token:(NSString *)address symbol:(NSString *)symbol {
    return [[Erc20Token alloc] initWithDictionary:@{@"address":address,@"symbol":symbol}];
}

+ (Erc20Token *)tokenFromDictionary:(NSDictionary *)dic {
    return [[Erc20Token alloc] initWithDictionary:dic];
}

- (instancetype)initWithDictionary: (NSDictionary*)info {
    self = [super init];
    if (self) {
        _address = [Address addressWithString:queryPath(info, @"dictionary:address/string")];
        if (!_address) {
            NSLog(@"ERROR: Missing token address");
        }
        
        _balance = queryPath(info, @"dictionary:balance/bigNumber");
        _image = queryPath(info, @"dictionary:images/string");
        _price = queryPath(info, @"dictionary:price/float");
        _cnyPrice = queryPath(info, @"dictionary:cnyPrice/float");
        _symbol = queryPath(info, @"dictionary:symbol/string");
        if (!_symbol) {
            _symbol =queryPath(info, @"dictionary:units/string");
        }
        _name = queryPath(info, @"dictionary:name/string");
    }
    return self;
}

- (NSDictionary*)dictionaryRepresentation {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:6];
    
    if (_address) {
        [info setObject:_address.checksumAddress forKey:@"address"];
    }
    
    if (_balance) {
        [info setObject:[_balance decimalString] forKey:@"balance"];
    }
    
    if (_image) {
        [info setObject:_image forKey:@"images"];
    }
    
    if (_symbol) {
        [info setObject:_symbol forKey:@"units"];
    }
    
    if (_name) {
        [info setObject:_name forKey:@"name"];
    }
    
    if (_price) {
        [info setObject:_price.stringValue forKey:@"price"];
    }
    
    if (_cnyPrice) {
        [info setObject:_cnyPrice.stringValue forKey:@"cnyPrice"];
    }
    
    return info;
}
@end
