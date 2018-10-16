//
//  NetWork+Brief.m
//  mrtc
//
//  Created by boundlessocean on 2018/9/3.
//  Copyright © 2018年 xycentury. All rights reserved.
//

#import "NetWork+Brief.h"
#import "NMErrorCode.h"
@implementation NetWork (Brief)
+ (instancetype)GET_URL:(NSString *)url
           parameterDic:(NSDictionary *)parameters
           successBlock:(success)success
           failureBlock:(failure)failure{
   return [self requestWithURL:url
                   requestType:NetWorkRequestTypeGET
                  parameterDic:parameters
                        images:nil
                  successBlock:success
                  failureBlock:failure];
}

+ (instancetype)POST_URL:(NSString *)url
           parameterDic:(NSDictionary *)parameters
           successBlock:(success)success
           failureBlock:(failure)failure{
    return [self requestWithURL:url
                    requestType:NetWorkRequestTypePOST
                   parameterDic:parameters
                         images:nil
                   successBlock:success
                   failureBlock:failure];
}


+ (instancetype)UPLOAD_URL:(NSString *)url
                    images:(NSArray<UIImage *> *)images
              parameterDic:(NSDictionary *)parameters
              successBlock:(success)success
              failureBlock:(failure)failure{
    return [self requestWithURL:url
                    requestType:NetWorkRequestTypeUPLOAD
                   parameterDic:parameters
                         images:images
                   successBlock:success
                   failureBlock:failure];
}


+ (instancetype)requestWithURL:(NSString *)url
                   requestType:(NetWorkRequestType)requestType
                  parameterDic:(NSDictionary *)parameters
                        images:(NSArray<UIImage *> *)images
                  successBlock:(success)success
                  failureBlock:(failure)failure{
    
    
    NSMutableDictionary *parametersData = [NSMutableDictionary dictionaryWithCapacity:0];
    !parameters ? : [parametersData addEntriesFromDictionary:parameters];
    
    NetWork *netWork = requestType == NetWorkRequestTypeGET ? [[self alloc] initWithUrlString:[self formatGETURL:url dict:parametersData]] :[[NetWork alloc]initWithHeaderName:url] ;
  
    netWork.timeOutSeconds = 20;
    
    if (requestType == NetWorkRequestTypePOST | requestType == NetWorkRequestTypeDELETE | requestType == NetWorkRequestTypePUT) {
        [netWork addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
        [netWork setPostBodyWithDic:parametersData];
        [netWork buildPostBody];
    } else if (requestType == NetWorkRequestTypeUPLOAD){
        [self formatUploadImageData:images parameterDic:parametersData netWork:netWork];
    }
    
    switch (requestType) {
            case NetWorkRequestTypeGET:
            netWork.requestMethod = @"GET";
            break;
            case NetWorkRequestTypeDELETE:
            netWork.requestMethod = @"DELETE";
            break;
            case NetWorkRequestTypePOST:
            case NetWorkRequestTypeUPLOAD:
            netWork.requestMethod = @"POST";
            break;
            case NetWorkRequestTypePUT:
            netWork.requestMethod = @"PUT";
            break;
        default:
            break;
    }
    
    __weak NetWork *net = netWork;
    [netWork setCompletionBlock:^{
        NSData *data = [net responseData];
        NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

        dispatch_async(dispatch_get_main_queue(), ^{
            !success ? : success(retDic);
        });
    }];
    [netWork setFailedBlock:^{
       
        NSData *data = [net responseData];
        NSString *message = [NMErrorCode descriptionWithErrorCode:net.error.code];
        if (data) {
            NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            message = retDic[@"msg"] ? retDic[@"msg"] : message;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            !failure ? : failure(message);
        });
    }];
    [netWork startAsynchronous];
    return netWork;
}



+ (void)formatUploadImageData:(NSArray *)images
                 parameterDic:(NSDictionary *)parameters
                      netWork:(NetWork *)netWork{
    for (UIImage *image in images){
        CGFloat dateValue = [NSDate date].timeIntervalSince1970;
        NSData *imageData = UIImageJPEGRepresentation(image,0.5);
        NSString *photoName = [NSString stringWithFormat:@"%f.jpg",dateValue];
        [netWork addData:imageData withFileName:photoName andContentType:@"image/jpeg" forKey:@"file"];
    }
    
    for (NSString *key in parameters.allKeys) {
        [netWork setPostValue:parameters[key] forKey:key];
    }
}


+ (NSString *)formatGETURL:(NSString *)url
                      dict:(__kindof NSDictionary *)dict {
    if (!dict) return url;
    NSString *URLSuffix = @"?";
    for (NSString *key in dict.allKeys) {
        NSString *value = [NSString stringWithFormat:@"%@=%@&",key,dict[key]];
        URLSuffix = [URLSuffix stringByAppendingString:value];
    }
    URLSuffix = [URLSuffix substringToIndex:URLSuffix.length - 1];
    url = [url stringByAppendingString:URLSuffix];
    return url;
}


@end
