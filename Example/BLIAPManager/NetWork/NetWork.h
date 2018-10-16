//
//  NetWork.h
//  toutiao
//
//  Created by ycl on 14-6-10.
//  Copyright (c) 2014年 xycentury. All rights reserved.
//
#import "ASIFormDataRequest.h"
#import <CommonCrypto/CommonDigest.h> // Need to import for CC_MD5 access


@interface NetWork : ASIFormDataRequest

- (void)addDeviceHeader;
- (id)initWithUrlString:(NSString *)urlString;
+ (id)requestWithUrlString:(NSString *)urlString;
- (NSDictionary *)getDataFromJson;

///网络请求封装
- (instancetype)initWithHeaderName:(NSString *)name;
- (void)setPostBodyWithDic:(NSDictionary *)dic;

@end


NSString* getDeviceId();
NSDictionary* getDeviceHeaders();