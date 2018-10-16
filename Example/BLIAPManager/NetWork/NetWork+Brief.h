//
//  NetWork+Brief.h
//  mrtc
//
//  Created by boundlessocean on 2018/9/3.
//  Copyright © 2018年 xycentury. All rights reserved.
//

#import "NetWork.h"
@class MTTableView;
typedef void (^success)(NSDictionary *responseObject);
typedef void (^failure)(NSString *error);

typedef NS_ENUM(NSInteger,NetWorkRequestType) {
    NetWorkRequestTypePOST,
    NetWorkRequestTypeGET,
    NetWorkRequestTypeDELETE,
    NetWorkRequestTypeUPLOAD,
    NetWorkRequestTypePUT,
};

@interface NetWork (Brief)

+ (instancetype)GET_URL:(NSString *)url
           parameterDic:(NSDictionary *)parameters
           successBlock:(success)success
           failureBlock:(failure)failure;

+ (instancetype)POST_URL:(NSString *)url
            parameterDic:(NSDictionary *)parameters
            successBlock:(success)success
            failureBlock:(failure)failure;

+ (instancetype)UPLOAD_URL:(NSString *)url
                    images:(NSArray <UIImage *> *)images
              parameterDic:(NSDictionary *)parameters
              successBlock:(success)success
              failureBlock:(failure)failure;

+ (instancetype)requestWithURL:(NSString *)url
                   requestType:(NetWorkRequestType)requestType
                  parameterDic:(NSDictionary *)parameters
                        images:(NSArray<UIImage *> *)images
                  successBlock:(success)success
                  failureBlock:(failure)failure;
@end
