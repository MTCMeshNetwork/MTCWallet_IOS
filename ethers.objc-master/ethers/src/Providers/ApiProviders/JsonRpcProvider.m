/**
 *  MIT License
 *
 *  Copyright (c) 2017 Richard Moore <me@ricmoo.com>
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included
 *  in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 *  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 *  DEALINGS IN THE SOFTWARE.
 */

#import "JsonRpcProvider.h"

#import "SecureData.h"
#import "Utilities.h"

@interface Provider (private)

- (void)setBlockNumber: (NSInteger)blockNumber;

@end


#pragma mark -
#pragma mark - JsonRpcProvider

@implementation JsonRpcProvider {
    NSUInteger _requestCount;
    NSTimer *_poller;
}

- (instancetype)initWithChainId:(ChainId)chainId url:(NSURL *)url {
    self = [super initWithChainId:chainId];
    if (self) {
        _url = url;
        [self doPoll];
    }
    return self;
}

- (void)dealloc {
    [_poller invalidate];
}

- (void)reset {
    [super reset];
    [self doPoll];
}


#pragma mark - Polling

- (void)doPoll {
    [[self getBlockNumber] onCompletion:^(IntegerPromise *promise) {
        if (promise.result) {
            [self setBlockNumber:promise.value];
        }
    }];
}

- (void)startPolling {
    if (self.polling) { return; }
    [super startPolling];
    _poller = [NSTimer scheduledTimerWithTimeInterval:4.0f target:self selector:@selector(doPoll) userInfo:nil repeats:YES];
}

- (void)stopPolling {
    if (!self.polling) { return; }
    [super stopPolling];
    [_poller invalidate];
    _poller = nil;
}


#pragma mark - Methods

- (id)sendMethod: (NSString*)method params: (NSObject*)params fetchType: (ApiProviderFetchType)fetchType {
    
    NSDictionary *request = @{
                              @"jsonrpc": @"2.0",
                              @"method": method,
                              @"id": @(42),
                              @"params": params,
                              };

    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:request options:0 error:&error];
    
    if (error) {
        NSDictionary *userInfo = @{@"reason": @"invalid JSON values", @"error": error};
        return [Promise rejected:[NSError errorWithDomain:ProviderErrorDomain code:ProviderErrorInvalidParameters userInfo:userInfo]];
    }

    NSObject* (^processResponse)(NSDictionary*) = ^NSObject*(NSDictionary *response) {
        NSDictionary *rpcError = [response objectForKey:@"error"];
        if (rpcError) {
            NSDictionary *userInfo = @{@"reason": [NSString stringWithFormat:@"%@", [rpcError objectForKey:@"message"]]};
            return [NSError errorWithDomain:ProviderErrorDomain code:ProviderErrorBadResponse userInfo:userInfo];
        }

        NSObject *result = [response objectForKey:@"result"];
        if (!result) {
            NSDictionary *userInfo = @{@"reason": @"invalid result"};
            return [NSError errorWithDomain:ProviderErrorDomain code:ProviderErrorBadResponse userInfo:userInfo];
        }
        return result; //coerceValue(result, fetchType);
    };
    
    return [self promiseFetchJSON:_url
                             body:body
                        fetchType:fetchType
                          process:processResponse];
}

- (BigNumberPromise*)getBalance:(Address *)address blockTag:(BlockTag)blockTag {
    NSObject *tag = getBlockTag(blockTag);
    
    if (!address || !tag ) {
        return [BigNumberPromise rejected:[NSError errorWithDomain:ProviderErrorDomain code:ProviderErrorInvalidParameters userInfo:@{}]];
    }
    
    return [self sendMethod:@"eth_getBalance"
                     params:@[ address.checksumAddress, tag ]
                  fetchType:ApiProviderFetchTypeBigNumberHexString];
}

- (IntegerPromise*)getTransactionCount:(Address *)address blockTag:(BlockTag)blockTag {
    NSObject *tag = getBlockTag(blockTag);

    if (!address || !tag) {
        return [IntegerPromise rejected:[NSError errorWithDomain:ProviderErrorDomain code:ProviderErrorInvalidParameters userInfo:@{}]];
    }
    
    return [self sendMethod:@"eth_getTransactionCount"
                     params:@[ address.checksumAddress, tag ]
                  fetchType:ApiProviderFetchTypeIntegerHexString];
}

- (DataPromise*)getCode: (Address*)address {
    if (!address) {
        return [DataPromise rejected:[NSError errorWithDomain:ProviderErrorDomain code:ProviderErrorInvalidParameters userInfo:@{}]];
    }
    
    return [self sendMethod:@"eth_getCode"
                     params:@[ address.checksumAddress , @"latest"]
                  fetchType:ApiProviderFetchTypeData];
}

- (IntegerPromise*)getBlockNumber {
    return [self sendMethod:@"eth_blockNumber" params:@[] fetchType:ApiProviderFetchTypeIntegerHexString];
}

- (BigNumberPromise*)getGasPrice {
    return [self sendMethod:@"eth_gasPrice" params:@[] fetchType:ApiProviderFetchTypeBigNumberHexString];
}

- (DataPromise*)call:(Transaction *)transaction {
    if (!transaction || !transaction.toAddress) {
        return [DataPromise rejected:[NSError errorWithDomain:ProviderErrorDomain code:ProviderErrorInvalidParameters userInfo:@{}]];
    }
    
    return [self sendMethod:@"eth_call"
                     params:@[ transactionObject(transaction), @"latest" ]
                  fetchType:ApiProviderFetchTypeData];
}

- (BigNumberPromise*)estimateGas:(Transaction *)transaction {
    if (!transaction) {
        return [BigNumberPromise rejected:[NSError errorWithDomain:ProviderErrorDomain code:ProviderErrorInvalidParameters userInfo:@{}]];
    }

    return [self sendMethod:@"eth_estimateGas"
                     params:@[ transactionObject(transaction)]
                  fetchType:ApiProviderFetchTypeBigNumberHexString];
}

- (HashPromise*)sendTransaction:(NSData *)signedTransaction {
    if (!signedTransaction) {
        return [HashPromise rejected:[NSError errorWithDomain:ProviderErrorDomain code:ProviderErrorInvalidParameters userInfo:@{}]];
    }

    return [self sendMethod:@"eth_sendRawTransaction"
                     params:@[ [SecureData dataToHexString:signedTransaction] ]
                  fetchType:ApiProviderFetchTypeHash];
}

- (BlockInfoPromise*)getBlockByBlockTag:(BlockTag)blockTag {
    NSObject *blockTagName = getBlockTag(blockTag);
    if (!blockTagName) {
        return [BlockInfoPromise rejected:[NSError errorWithDomain:ProviderErrorDomain code:ProviderErrorInvalidParameters userInfo:@{}]];
    }
    
    return [self sendMethod:@"eth_getBlockByNumber"
                     params:@[blockTagName, @(NO)]
                  fetchType:ApiProviderFetchTypeBlockInfo];
}

- (BlockInfoPromise*)getBlockByBlockHash:(Hash *)blockHash {
    if (!blockHash) {
        return [BlockInfoPromise rejected:[NSError errorWithDomain:ProviderErrorDomain code:ProviderErrorInvalidParameters userInfo:@{}]];
    }
    
    return [self sendMethod:@"eth_getBlockByHash"
                     params:@[blockHash.hexString, @(NO)]
                  fetchType:ApiProviderFetchTypeBlockInfo];
}

- (TransactionInfoPromise*)getTransaction:(Hash *)transactionHash {
    if (!transactionHash) {
        return [TransactionInfoPromise rejected:[NSError errorWithDomain:ProviderErrorDomain code:ProviderErrorInvalidParameters userInfo:@{}]];
    }
    
    return [self sendMethod:@"eth_getTransactionByHash"
                     params:@[transactionHash.hexString]
                  fetchType:ApiProviderFetchTypeTransactionInfo];
}

- (HashPromise*)getStorageAt:(Address *)address position:(BigNumber *)position {
    if (!address) {
        return [HashPromise rejected:[NSError errorWithDomain:ProviderErrorDomain code:ProviderErrorInvalidParameters userInfo:@{}]];
    }
    
    return [self sendMethod:@"eth_getStorageAt"
                     params:@[ address.checksumAddress, stripHexZeros([position hexString]), @"latest" ]
                  fetchType:ApiProviderFetchTypeHash];
}

//custom
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
                NSObject *tokenCounts = [info objectForKey:@"tokenCounts"];
                if (tokenCounts) {
                    [mutableInfo setObject:tokenCounts forKey:@"value"];
                }
                
                NSObject *data = [info objectForKey:@"input"];
                if (data) {
                    [mutableInfo setObject:data forKey:@"data"];
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
    NSString *url = [NSString stringWithFormat:@"https://wallet.mtc.io/rpc/tl?i=1&c=100&a=%@",address];
    
    return [self promiseFetchJSON:[NSURL URLWithString:url]
                             body:nil
                        fetchType:ApiProviderFetchTypeArray
                          process:processTransactions];
}

- (ArrayPromise *)getTokenBalance:(NSString *)address {
    NSObject *(^processTokens)(NSDictionary *) = ^NSObject*(NSDictionary *response) {
//        NSLog(@"%@获取余额：%@",address,response);
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
    NSString *url = [NSString stringWithFormat:@"https://wallet.mtc.io/rpc/cl?address=%@",address];
    return [self promiseFetchJSON:[NSURL URLWithString:url]
                         body:nil
                    fetchType:ApiProviderFetchTypeArray
                      process:processTokens];
}



#pragma mark - NSObject

- (NSString*)description {
    return [NSString stringWithFormat:@"<JsonRpcProvider chainId=%d url=%@>", self.chainId, _url];
}

@end
