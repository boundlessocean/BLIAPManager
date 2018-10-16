//
//  BLIAPManager.m
//  BLIAPManager
//
//  Created by boundlessocean on 2018/10/14.
//

#import "BLIAPManager.h"
#import <CommonCrypto/CommonCrypto.h>

@interface BLIAPManager ()<SKPaymentTransactionObserver,SKProductsRequestDelegate>
/** 检索产品请求 */
@property (nonatomic ,strong) SKProductsRequest *productRequest;
/** 所以内购产品 */
@property (nonatomic ,strong) NSArray<SKProduct *> *products;
/** 检索回调 */
@property(nonatomic,copy) void (^cheakComplete)(NSArray<SKProduct *> *, NSArray<NSString *> *, BLIAPError);
/** 交易请求 */
@property (nonatomic ,strong) SKMutablePayment *payment;
/** 未完成交易处理 */
@property(nonatomic,copy) void (^transactionsHandle)(NSMutableArray <BLIAPTransactionOrder *> *);
/** 与iTunes交易完成 */
@property(nonatomic,copy) void (^transactionComplete)(BLIAPTransactionOrder * ,BLIAPError );
@end
@implementation BLIAPManager

+ (instancetype)shareIAPManager{
    static BLIAPManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}



#pragma mark - - Public
- (void)configTransactionObserver{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)cheakProducts:(NSSet<NSString *> *)productIdentifiers
             complete:(void (^)(NSArray<SKProduct *> *,
                                NSArray<NSString *> *,
                                BLIAPError ))cheakComplete{
    _cheakComplete = cheakComplete;
    _productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    _productRequest.delegate = self;
    [_productRequest start];
}

- (void)requestPayment:(NSString *)oderJson
    productIdentifiers:(NSString *)productIdentifiers
              complete:(void (^)(BLIAPTransactionOrder * ,BLIAPError ))transactionComplete{
    _transactionsHandle = nil;
    _transactionComplete = transactionComplete;
    // 未开启内购功能
    if (![SKPaymentQueue canMakePayments]) {
        !transactionComplete ? : transactionComplete(nil,BLIAPErrorCheakIAPState);
    } else {
    // 已开启内购功能
        SKProduct *productMacth;
        for (SKProduct *product in _products) {
            if ([product.productIdentifier isEqualToString:productIdentifiers]) {
                productMacth = product;
            }
        }
        // 匹配到产品
        if (productMacth) {
            _payment = [SKMutablePayment paymentWithProduct:productMacth];
            _payment.applicationUsername = oderJson;
            [[SKPaymentQueue defaultQueue] addPayment:_payment];
        } else {
        // 未匹配到产品
            !transactionComplete ? : transactionComplete(nil,BLIAPErrorUnableFindProduct);
        }
    }
}

- (void)handleUnfinishTransaction:(void (^)(NSMutableArray<BLIAPTransactionOrder *> *))transactionsHandle{
    _transactionsHandle = transactionsHandle;
}

- (void)cheakTransactionOrder:(NSString *)orderJson
                     complete:(void (^)(BLIAPTransactionOrder *, BLIAPError))complete{
    BLIAPError error = BLIAPErrorNone;
    for (SKPaymentTransaction *transaction in [SKPaymentQueue defaultQueue].transactions) {
        if ([transaction.payment.productIdentifier isEqualToString:orderJson]) {
            error = BLIAPErrorNone;
            if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
                !complete ? : complete([self initializeOrder:transaction],error);
                return;
            } else {
                error = BLIAPErrorTransactionStateUnpay;
            }
            break;
        } else {
            error = BLIAPErrorUnableFindProduct;
        }
    }
    !complete ? : complete(nil,error);
}

+ (void)finishTransaction:(NSString *)orderJson{
    NSArray<SKPaymentTransaction *> *transactions = [[SKPaymentQueue defaultQueue].transactions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"payment.applicationUsername CONTAINS %@",orderJson]];
    if (transactions.count) {
        [[SKPaymentQueue defaultQueue] finishTransaction:transactions.firstObject];
    }
}

#pragma mark - - SKRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response{
    _products = response.products;
    !_cheakComplete ? : _cheakComplete(response.products,
                                       response.invalidProductIdentifiers,
                                       BLIAPErrorNone);
}

- (void)request:(SKRequest *)request
didFailWithError:(NSError *)error{
    !_cheakComplete ? : _cheakComplete(nil,
                                       nil,
                                       BLIAPErrorUnableConnectiTunseStore);
}



#pragma mark - - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue
 updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    NSMutableArray <BLIAPTransactionOrder *> *unFinishTransactions = [NSMutableArray arrayWithCapacity:0];
    BLIAPError error = BLIAPErrorNone;
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState){
            case SKPaymentTransactionStatePurchased:{
                BLIAPTransactionOrder *order = [self initializeOrder:transaction];
                [unFinishTransactions addObject:order];
                break;
            }
            case SKPaymentTransactionStateFailed:
                error = BLIAPErrorTransactionStateFailed;
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:
            case SKPaymentTransactionStateDeferred:
            case SKPaymentTransactionStateRestored:
                return;
        }
    }
    if (_transactionsHandle && unFinishTransactions.count) {
        _transactionsHandle(unFinishTransactions);
    } else if (_transactionComplete){
        _transactionComplete(unFinishTransactions.firstObject,error);
    }
}

#pragma mark - - Private

/** 配置订单 */
- (BLIAPTransactionOrder *)initializeOrder:(SKPaymentTransaction *)transaction{
    NSURL *rereceiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:rereceiptURL];
    BLIAPTransactionOrder *order = [BLIAPTransactionOrder new];
    order.oderJson = transaction.payment.applicationUsername;
    order.receiptData = [receiptData base64EncodedStringWithOptions:0];
    return order;
}

/** SHA-256 哈希 */
- (NSString *)hashedValueForAccountName:(NSString*)userAccountName{
    
    if (!userAccountName) {
        userAccountName = BLIAPManager.deviceUDID;
    }
    const int HASH_SIZE = 32;
    unsigned char hashedChars[HASH_SIZE];
    const char *accountName = [userAccountName UTF8String];
    size_t accountNameLen = strlen(accountName);
    if (accountNameLen > UINT32_MAX) {
        NSLog(@"Account name too long to hash: %@", userAccountName);
        return nil;
    }
    CC_SHA256(accountName, (CC_LONG)accountNameLen, hashedChars);
    NSMutableString *userAccountHash = [[NSMutableString alloc] init];
    for (int i = 0; i < HASH_SIZE; i++) {
        if (i != 0 && i%4 == 0) {
            [userAccountHash appendString:@"-"];
        }
        [userAccountHash appendFormat:@"%02x", hashedChars[i]];
    }
    return userAccountHash;
}


+ (NSString *)deviceUDID{
    NSString *deviceUDID = [[NSUbiquitousKeyValueStore defaultStore] objectForKey:[[NSBundle mainBundle].bundleIdentifier stringByAppendingString:@"deviceUDID"]];
    if (!deviceUDID) {
        deviceUDID = [UIDevice currentDevice].identifierForVendor.UUIDString;
        [[NSUbiquitousKeyValueStore defaultStore] setObject:deviceUDID forKey:[[NSBundle mainBundle].bundleIdentifier stringByAppendingString:@"deviceUDID"]];
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    }
    return deviceUDID;
}
@end


@implementation BLIAPTransactionOrder
@end
