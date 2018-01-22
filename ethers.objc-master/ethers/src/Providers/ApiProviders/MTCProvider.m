//
//  MTCProvider.m
//  ethers
//
//  Created by thomasho on 2018/1/20.
//  Copyright © 2018年 Ethers. All rights reserved.
//

#import "MTCProvider.h"

@implementation MTCProvider

- (instancetype)initWithChainId:(ChainId)chainId {
    NSString *host = nil;
    switch (chainId) {
        case ChainIdHomestead:
            host = @"p.mtc.io/rpc/api";
            break;
        case ChainIdKovan:
        case ChainIdMorden:
        case ChainIdRinkeby:
        case ChainIdRopsten:
        case ChainIdPrivate:
        case ChianIdAny:
            host = @"192.168.1.84";
            break;
    }
    
    // Any other host is not supported
    if (!host) { return nil; }

    NSString *url = [NSString stringWithFormat:@"http://%@", host];
    self = [super initWithChainId:chainId url:[NSURL URLWithString:url]];
    if (self) {
    }
    return self;
}

- (ArrayPromise*)getTransactions: (Address*)address startBlockTag: (BlockTag)blockTag {
    NSObject* (^processTransactions)(NSDictionary*) = ^NSObject*(NSDictionary *response) {
        NSMutableArray *result = [NSMutableArray array];
        
        NSArray *infos = (NSArray*)[[response objectForKey:@"obj"] objectForKey:@"list"];
        if (![infos isKindOfClass:[NSArray class]]) {
            return [NSError errorWithDomain:ProviderErrorDomain code:ProviderErrorBadResponse userInfo:@{}];
        }
        
        for (NSDictionary *info in infos) {
            if (![info isKindOfClass:[NSDictionary class]]) {
                return [NSError errorWithDomain:ProviderErrorDomain code:ProviderErrorBadResponse userInfo:@{}];
            }
            
            NSMutableDictionary *mutableInfo = [info mutableCopy];
            
            // Massage some values that have their key names differ from ours
            {
                NSObject *gasLimit = [info objectForKey:@"gas"];
                if (gasLimit) {
                    [mutableInfo setObject:gasLimit forKey:@"gasLimit"];
                }
                
                NSString *timestamp = [NSString stringWithFormat:@"%@",[info objectForKey:@"time"]];
                if (timestamp.length) {
                    [mutableInfo setObject:(timestamp.length>12)?[timestamp substringToIndex:timestamp.length-3]:timestamp forKey:@"timestamp"];
                }
                
                //代币合约
                NSString *contractAddress = [NSString stringWithFormat:@"%@",[info objectForKey:@"contractAddress"]];
                NSString *toAddress = [info objectForKey:@"to"];
                if (contractAddress.length == 42) {
                    //to依旧处理为->代币tokenAddress，用户则保持->tokenTo
                    [mutableInfo removeObjectForKey:@"to"];
                    [mutableInfo setObject:contractAddress forKey:@"to"];
                    NSObject *data = [info objectForKey:@"data"];
                    if (!data) {
                        SecureData *tokenData = [SecureData secureDataWithCapacity:68];
                        [tokenData appendData:[SecureData hexStringToData:@"0xa9059cbb000000000000000000000000"]];
                        toAddress = [toAddress hasPrefix:@"0x"]?toAddress:[@"0x" stringByAppendingString:toAddress];
                        [tokenData appendData:[SecureData hexStringToData:toAddress]];
                        BigNumber *tokenValue = [BigNumber bigNumberWithDecimalString:[NSString stringWithFormat:@"%@",[info valueForKey:@"tokenCounts"]]];
                        NSInteger len = tokenValue.data.length;
                        while (len++ < 32) {
                            [tokenData appendData:[SecureData hexStringToData:@"0x00"]];
                        }
                        [tokenData appendData:tokenValue.data];
                        [mutableInfo setObject:tokenData.data forKey:@"data"];
                    }
                }
            }
        
            TransactionInfo *transactionInfo = [TransactionInfo transactionInfoFromDictionary:mutableInfo];
            if (!transactionInfo) {
                return [NSError errorWithDomain:ProviderErrorDomain code:ProviderErrorBadResponse userInfo:@{}];
            }
            
            [result addObject:transactionInfo];
        }
        
        return result;
    };
    //    NSString *url = [NSString stringWithFormat:@"http://192.168.1.84:8081/tx/t2?i=1&c=100&a=%@",address];
    NSString *url = [NSString stringWithFormat:@"http://p.mtc.io/rpc/tl?i=1&c=100&a=%@",address];
    
    return [self promiseFetchJSON:[NSURL URLWithString:url]
                             body:nil
                        fetchType:ApiProviderFetchTypeArray
                          process:processTransactions];
}

- (ArrayPromise *)getTokenBalance:(NSString *)address {
    NSObject *(^processTokens)(NSDictionary *) = ^NSObject*(NSDictionary *response) {
        if ([[response valueForKey:@"code"] integerValue] != 200) {
            return [NSError errorWithDomain:ProviderErrorDomain code:ProviderErrorBadResponse userInfo:response];
        }
        NSMutableArray *result = [NSMutableArray array];
        NSArray *tokens = [response valueForKey:@"obj"];
        for (NSDictionary *info in tokens) {
            Erc20Token *token = [Erc20Token tokenFromDictionary:info];
            if (!token) {
                return [NSError errorWithDomain:ProviderErrorDomain code:ProviderErrorBadResponse userInfo:@{}];
            }
            [result addObject:token];
        }
        return result;
    };
    //    NSString *url = [NSString stringWithFormat:@"http://192.168.1.84:8081/tx/t6?address=%@",address];
    NSString *url = [NSString stringWithFormat:@"http://p.mtc.io/rpc/cl?address=%@",address];
    return [self promiseFetchJSON:[NSURL URLWithString:url]
                             body:nil
                        fetchType:ApiProviderFetchTypeArray
                          process:processTokens];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<MTCProvider chainId=%d>", self.chainId];
}

@end
