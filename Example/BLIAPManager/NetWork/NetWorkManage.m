//
//  NetWorkManage.m
//  baseproject
//
//  Created by ycl on 15/6/15.
//  Copyright (c) 2015年 xycentury. All rights reserved.
//

#import "NetWorkManage.h"

@implementation NetWorkManage

+ (NetWorkManage *)shareNetWorkManage
{
    static dispatch_once_t once;
    static NetWorkManage *shareManage = nil;
    dispatch_once(&once, ^{
        shareManage = [[self alloc]init];
    });
    return shareManage;
}


- (NetWork *)requestWithURL:(NSString *)url
               parameterDic:(NSDictionary *)parameters
               successBlock:(success)success
               failureBlock:(failure)failure
{
    return [self requestWithURL:url parameterDic:parameters fileDic:nil successBlock:success failureBlock:failure timeOutSeconds:20];
}

- (NetWork *)requestWithURL:(NSString *)url
               parameterDic:(NSDictionary *)parameters
               successBlock:(success)success
               failureBlock:(failure)failure
             timeOutSeconds:(int)second
{
    return [self requestWithURL:url parameterDic:parameters fileDic:nil successBlock:success failureBlock:failure timeOutSeconds:second];
}

- (NetWork *)requestWithURL:(NSString *)url
               parameterDic:(NSDictionary *)parameters
                    fileDic:(NSDictionary *)fileparameters
               successBlock:(success)success
               failureBlock:(failure)failure
{
    return [self requestWithURL:url parameterDic:parameters fileDic:fileparameters successBlock:success failureBlock:failure timeOutSeconds:20];
}


- (NetWork *)requestWithURL:(NSString *)url
               parameterDic:(NSDictionary *)parameters
                    fileDic:(NSDictionary *)fileparameters
               successBlock:(success)success
               failureBlock:(failure)failure
             timeOutSeconds:(int)second
{
    NetWork *request = [NetWork requestWithURL:[NSURL URLWithString:url]];
    [request addDeviceHeader];
    if (second < 10) {
        second =100;
    }
    if([[[[NSURL URLWithString:url] scheme] lowercaseString] isEqualToString:@"https"]) {
        request.validatesSecureCertificate = NO;
    }
    request.timeOutSeconds = second;
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    [request setRequestMethod:@"POST"];
    for (NSString *key in parameters.allKeys){
        NSString *value = [parameters objectForKey:key];
        [request setPostValue:value forKey:key];
    }
    
    for (NSString *key in fileparameters.allKeys){
        NSString *value = [fileparameters objectForKey:key];
        [request setFile:value forKey:key];
    }
    __weak NetWork *net = request;
    [request setCompletionBlock:^{
        NSData *data = [net responseData];
       
        NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (!retDic.count) {
            retDic = @{@"code":@"-88888888",@"msg":@"网络超时，请刷新重试！"};
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            success(retDic);
        });
    }];
    [request setFailedBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *msg = @"网络不给力，请刷新重试！";
            failure(msg);
        });
    }];
    [request buildPostBody];
    [request startAsynchronous];
    
    return request;
}


@end
