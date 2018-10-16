//
//  NetWork.m
//  toutiao
//
//  Created by ycl on 14-6-10.
//  Copyright (c) 2014年 xycentury. All rights reserved.
//

#import "NetWork.h"
#import "sys/utsname.h"
#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/AdSupport.h>
@implementation NetWork

#define DeviceIdKEY @"artronDeviceId"  //设备识别码保存本地的键值
#define ArtronEncryptKey @"7f9jofld0kmmfdd#&?fdjfkd" //与后台通信加密的秘钥

- (instancetype)initWithHeaderName:(NSString *)name{
    
    self = [super initWithUrlString:name];
    if (self) {
        
        [self addRequestHeader:@"X-Target" value:name];
        NSString *IosVersion = [[UIDevice currentDevice] systemVersion];
        NSString *DeviceId = getDeviceId();
        NSDictionary *infoDictionary =[[NSBundle mainBundle]infoDictionary];
        NSString *Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        [self addRequestHeader:@"OS" value:[NSString stringWithFormat:@"IOS,%@,%@,%@",IosVersion,DeviceId,Version]];
        [self addRequestHeader:@"APIV" value:Version];
        [self addRequestHeader:@"KIND" value:@"toucai"];
    }
    return self;
}

- (void)setPostBodyWithDic:(NSDictionary *)dic{
    
    NSError *nowerror;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error: &nowerror];
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    [self setPostBody:tempJsonData];
}

- (id)initWithUrlString:(NSString *)urlString{

    [self addDeviceHeader];
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (void)addDeviceHeader{
    NSDictionary *dic = getDeviceHeaders();
//    for (NSString *key in dic) {
//        [self addRequestHeader:key value:[dic objectForKey:key]];
//    }
//    [self addRequestHeader:@"OS" value:[dic dictToJson]];
}


NSDictionary* getDeviceHeaders() {
    NSMutableDictionary *headsdic = [[NSMutableDictionary alloc] init];
 
    NSString *DeviceId = getDeviceId();
    [headsdic setValue:DeviceId forKey:@"DEVICEID"];
    
    NSString *IosVersion = [[UIDevice currentDevice] systemVersion];
    [headsdic setValue:IosVersion forKey:@"IOSVERSION"];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [headsdic setValue:appVersion forKey:@"APPVERSION"];
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *DeviceType = [NSString stringWithFormat:@"%@",[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding]];
    [headsdic setValue:DeviceType forKey:@"DEVICETYPE"];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    NSInteger ScreenWidth = size.width;
    NSInteger ScreenHeight = size.height;
    NSInteger ScreenScale = [UIScreen mainScreen].scale;
 
    
    [headsdic setValue:[NSString stringWithFormat:@"%ld",(long)ScreenWidth] forKey:@"SCREENWIDTH"];
    [headsdic setValue:[NSString stringWithFormat:@"%ld",(long)ScreenHeight] forKey:@"SCREENHEIGHT"];
    [headsdic setValue:[NSString stringWithFormat:@"%ld",(long)ScreenScale] forKey:@"SCREENSCALE"];
 
    
    NSString *headerSecrety = [NSString stringWithFormat:@"%@", getMd5_32Bit_String([NSString stringWithFormat:@"%@|%@|%@|%@|%ld|%ld|%ld|%@", DeviceId, IosVersion, DeviceType, appVersion, (long)ScreenWidth, (long)ScreenHeight, (long)ScreenScale, ArtronEncryptKey])];
    [headsdic setValue:headerSecrety forKey:@"MD5KEY"];
    
    return headsdic;
    
}



NSString* getDeviceId()
{
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    
//    NSString *keychainservice = [infoDictionary objectForKey:@"CFBundleIdentifier"];;
//    NSString *keychainaccount = @"mrtc";
//    
    NSString *DeviceId;
//    DeviceId = [SSKeychain passwordForService:keychainservice account:keychainaccount];
    DeviceId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
//    if(DeviceId == nil){
//        NSString *DeviceIdCache = [Tool getCache:@"DeviceIdCache"];
//        if (!DeviceIdCache || [Tool isBlankString:DeviceIdCache]) {
//            
////            CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
////            DeviceId = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
////            CFRelease(uuidRef);
//            DeviceId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
//            [Tool setCache:@"DeviceIdCache" value:DeviceId];
//        }else{
//            DeviceId = DeviceIdCache;
//        }
//        
//        [SSKeychain setPassword: [NSString stringWithFormat:@"%@", DeviceId]
//                     forService:keychainservice account:keychainaccount];
//        
//    }
    
    
    return DeviceId;
}

NSString *getMd5_32Bit_String( NSString * srcString)
{
    
    const char *cStr = [srcString UTF8String ];
    
    unsigned char digest[ CC_MD5_DIGEST_LENGTH ];
    
    CC_MD5 ( cStr, (CC_LONG)strlen (cStr), digest );
    
    NSMutableString *result = [ NSMutableString stringWithCapacity : CC_MD5_DIGEST_LENGTH * 2 ];
    
    for ( int i = 0 ; i < CC_MD5_DIGEST_LENGTH ; i++)
        
        [result appendFormat : @"%02x" , digest[i]];
    
    return result;
}

+ (id)requestWithUrlString:(NSString *)urlString
{
    return [[self alloc] initWithUrlString:urlString];
}

- (NSDictionary *)getDataFromJson{
    
    NSDictionary *dic;
    if (!self.responseData) {
        dic = nil;
    }else{
        dic = [NSJSONSerialization JSONObjectWithData:self.responseData
                                              options:NSJSONReadingAllowFragments
                                                error:nil];
    }
    
    if (dic.count) {
        
        NSInteger code = [[dic objectForKey:@"Code"]integerValue];
        if (code == 9999) {
            
        }
        return dic;
    }else{
        return @{@"Code":@"-88888888",@"desc":@"网络超时，请刷新重试！"};
    }
}


@end
