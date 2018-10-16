//
//  NMErrorCode.m
//  NMWalletAPP
//
//  Created by boundlessocean on 2017/4/21.
//  Copyright © 2017年 Lemon. All rights reserved.
//

#import "NMErrorCode.h"

@implementation NMErrorCode

+ (NSString *)descriptionWithErrorCode:(NSInteger)code{
    NSDictionary *errorDict = @{  @-1 : @"未知错误",
                                  @-999 : @"请求已取消",
                                  @-1000 : @"URL地址错误",
                                  @-1001 : @"连接超时",
                                  @-1002 : @"不支持的URL",
                                  @-1003 : @"连接服务器失败",
                                  @-1004 : @"连接服务器失败",
                                  @-1103 : @"URL超出字节限制",
                                  @-1005 : @"连接丢失",
                                  @-1006 : @"DNS解析错误",
                                  @-1007 : @"HTTP重定向过多",
                                  @-1008 : @"无法检索所请求的资源",
                                  @-1009 : @"请检查您的网络",
                                  @-1010 : @"重定向位置不存在",
                                  @-1011 : @"服务器响应错误",
                                  @-1014 : @"未获取到数据",
                                  @-1015 : @"解码失败",
                                  @-1016 : @"解码失败",
                                  @-1017 : @"未能响应解析",
                                  @-1100 : @"资源不存在",
                                  @-1101 : @"请求为目录地址",
                                  @-1102 : @"权限不足",
                                  @-1103 : @"权限不足",
                                  @-1200 : @"证书配置错误",
                                  @-1201 : @"证书配置错误",
                                  @-1202 : @"证书配置错误",
                                  @-1203 : @"证书配置错误",
                                  @-1204 : @"证书配置错误",
                                  @-1205 : @"证书配置错误",
                                  @-1206 : @"证书配置错误",
                                  @-2000 : @"加载缓存错误",
                                  @-3000 : @"写入文件失败",
                                  @-3001 : @"写入文件失败",
                                  @-3002 : @"写入文件失败",
                                  @-3003 : @"写入文件失败",
                                  @-3004 : @"写入文件失败",
                                  @-3005 : @"写入文件失败",
                                  @-3006 : @"解码编码文件失败",
                                  @-3007 : @"解码编码文件失败"};
    NSString *descriptionStr = errorDict[[NSNumber numberWithInteger:code]] == nil ? @"请求失败" : errorDict[[NSNumber numberWithInteger:code]];
    return descriptionStr;
}
@end
