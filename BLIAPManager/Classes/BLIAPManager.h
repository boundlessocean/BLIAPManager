//
//  BLIAPManager.h
//  BLIAPManager
//
//  Created by boundlessocean on 2018/10/14.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
@class BLIAPTransactionOrder;
typedef NS_ENUM(NSInteger ,BLIAPError){
    BLIAPErrorNone,
    // 不能连接iTunseStore
    BLIAPErrorUnableConnectiTunseStore,
    // 没有找到该产品
    BLIAPErrorUnableFindProduct,
    // 用户未开启内购功能
    BLIAPErrorCheakIAPState,
    // 交易失败
    BLIAPErrorTransactionStateFailed,
    // 未付款
    BLIAPErrorTransactionStateUnpay,
};

@interface BLIAPManager : NSObject

+ (instancetype)shareIAPManager;

/**
 获取设备唯一标识
 */
+ (NSString *)deviceUDID;

// ----------------------------------------------------------------
// ------------- 第一部分 在AppDelegate处理交易未完成的订单 -------------
// ----------------------------------------------------------------
/**
  配置交易观察者
  需要在 AppDelegate -application:didFinishLaunchingWithOptions:中调用
 */
- (void)configTransactionObserver;

/**
  处理未完成的交易
  需要在 AppDelegate -application:didFinishLaunchingWithOptions:中调用
 @param transactionsHandle 回调未完成的订单
 */
- (void)handleUnfinishTransaction:(void(^)(NSMutableArray<BLIAPTransactionOrder *> * transactionOrder))transactionsHandle;


// ----------------------------------------------------------------
// --- 第二部分 再展示产品之前先检验服务器产品合法性，移除不合法产品，再显示 ---
// ----------------------------------------------------------------
/**
  向iTunes store检索产品合法性
 
 @param productIdentifiers 产品标示的数组
 @param cheakComplete 检索完回调结果
  products : 有效的产品
  invalidProductIdentifiers : 无效产品标识, 如果有数据：去除服务器返回的无效产品标示，在界面展示有效产品
  error : 请提示用户未能连接到iTunes store
 */

- (void)cheakProducts:(NSSet<NSString *> *)productIdentifiers
             complete:(void(^)(NSArray<SKProduct *> *products,
                               NSArray<NSString *> *invalidProductIdentifiers,
                               BLIAPError error))cheakComplete;

/**
 对具体产品发起购买

 @param oderJson 服务器返回的订单
 @param productIdentifiers 产品标识
 @param transactionComplete 完成与iTunes交易回调
 */
- (void)requestPayment:(NSString *)oderJson
    productIdentifiers:(NSString *)productIdentifiers
              complete:(void(^)(BLIAPTransactionOrder *transactionOrder,
                                BLIAPError error))transactionComplete;


// ----------------------------------------------------------------
// -- 第三部分 用户在资金流失／订单页面点击已付款未完成的订单继续让服务器校验 --
// ----------------------------------------------------------------
/**
 通过订单获取未完成的交易

 @param orderJson 订单json字符串
 @param complete 查询结果回调
 */
- (void)cheakTransactionOrder:(NSString *)orderJson
                     complete:(void(^)(BLIAPTransactionOrder *order,
                                       BLIAPError error))complete;


// ----------------------------------------------------------------
// ------ 第四部分 服务器验证完凭证（不管验证的结果）通知iTunes交易完成 ------
// ----------------------------------------------------------------
/**
 向iTunes通知这笔交易完成

 @param orderJson 订单
 */
+ (void)finishTransaction:(NSString *)orderJson;


@end

@interface BLIAPTransactionOrder : NSObject
/** 订单信息 */
@property (nonatomic ,strong) NSString *oderJson;
/** 票据 */
@property (nonatomic ,strong) NSString *receiptData;
/** 交易id */
@property (nonatomic, strong) NSString *transactionID;
/** 产品ID */
@property (nonatomic, strong) NSString *productID;
@end
