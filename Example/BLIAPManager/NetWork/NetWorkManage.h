//
//  NetWorkManage.h
//  baseproject
//
//  Created by ycl on 15/6/15.
//  Copyright (c) 2015年 xycentury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetWork.h"
/**
 *  成功---请求数据返回block
 *
 *  @param responseObject 返回数据data
 */
typedef void (^success)(NSDictionary *responseObject);
/**
 *  失败---请求数据失败block
 *
 *  @param error 返回数据的错误
 */
typedef void (^failure)(NSString *error);

@interface NetWorkManage : NSObject
/**
 *  单利--初始化管理类
 *
 *  @return 返回管理类
 */
+ (NetWorkManage *)shareNetWorkManage;
/**
 *  请求数据接口
 *
 *  @param url        接口的URL
 *  @param parameters 接口的请求参数
 *  @param success    请求成功之后返回的block
 *  @param failure    请求失败之后返回的block
 *  @return 返回请求的request
 */
- (NetWork *)requestWithURL:(NSString *)url
              parameterDic:(NSDictionary *)parameters
              successBlock:(success)success
              failureBlock:(failure)failure;

/**
 *  请求数据接口,带设置超时时间
 *
 *  @param url        接口的URL
 *  @param parameters 接口的请求参数
 *  @param success    请求成功之后返回的block
 *  @param failure    请求失败之后返回的block
 *  @param second     自定义超时时间
 *  @return 返回请求的request
 */
- (NetWork *)requestWithURL:(NSString *)url
              parameterDic:(NSDictionary *)parameters
              successBlock:(success)success
              failureBlock:(failure)failure
            timeOutSeconds:(int)second;

/**
 *  上传文件接口
 *
 *  @param url        接口的URL
 *  @param parameters 接口的请求参数
 *  @param fileparameters 上传文件的请求参数
 *  @param success    请求成功之后返回的block
 *  @param failure    请求失败之后返回的block
 *  @return 返回请求的request
 */

- (NetWork *)requestWithURL:(NSString *)url
              parameterDic:(NSDictionary *)parameters
              fileDic:(NSDictionary *)fileparameters
              successBlock:(success)success
              failureBlock:(failure)failure;

/**
 *  上传文件接口,带设置超时时间
 *
 *  @param url        接口的URL
 *  @param parameters 接口的请求参数
 *  @param fileparameters 上传文件的请求参数
 *  @param success    请求成功之后返回的block
 *  @param failure    请求失败之后返回的block
 *  @param second     自定义超时时间
 *  @return 返回请求的request
 */

- (NetWork *)requestWithURL:(NSString *)url
              parameterDic:(NSDictionary *)parameters
                   fileDic:(NSDictionary *)fileparameters
              successBlock:(success)success
              failureBlock:(failure)failure
         timeOutSeconds:(int)second;

@end
