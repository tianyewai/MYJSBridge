//
//  MYJSBUtil.h
//
//  Created by tianyewai on 2021/11/8.
//

#import <Foundation/Foundation.h>

#if DEBUG

#define MYJSBLog(xx, ...)   NSLog(@"MYJSBLog: " xx, ##__VA_ARGS__)

#else

#define MYJSBLog(xx, ...)   nil

#endif

static NSInteger const MYJSBInvalidCallCode = -1;
static NSInteger const MYJSBCallSucceedCode = 0;
static NSInteger const MYJSBAsynCallingCode = 1;

static NSString * _Nonnull const MYJSBInitCode = @"window._nativewk=true;";

static NSString * _Nonnull const MYJSBPromptPrefix = @"_nbbridge=";

static NSString * _Nonnull const MYJSBArgsCodeKey     = @"code";
static NSString * _Nonnull const MYJSBArgsDataKey     = @"data";
static NSString * _Nonnull const MYJSBArgsCallbackKey = @"_nbstub";

static NSString * _Nonnull const MYJSBAsynMethodCallbackHandler = @"callback";

#define MYJSBJsonBlankString @"{}"

#define MYJSBSucceedReturnObject @{MYJSBArgsCodeKey : @(MYJSBCallSucceedCode), MYJSBArgsDataKey : @""}
#define MYJSBSucceedReturnString [MYJSBUtil objectToJsonString:MYJSBSucceedReturnObject]

#define MYJSBInvalidReturnObject @{MYJSBArgsCodeKey : @(MYJSBInvalidCallCode), MYJSBArgsDataKey : [NSNull null]}
#define MYJSBInvalidReturnString [MYJSBUtil objectToJsonString:MYJSBInvalidReturnObject]

#define MYJSBAsynCallingReturnObject @{MYJSBArgsCodeKey : @(MYJSBAsynCallingCode), MYJSBArgsDataKey : @""}
#define MYJSBAsynCallingReturnString [MYJSBUtil objectToJsonString:MYJSBAsynCallingReturnObject]


NS_ASSUME_NONNULL_BEGIN

@interface MYJSBUtil : NSObject

/**
 * NSDictionary、NSArray转JSON字符串
 *
 * @param object NSDictionary、NSArray对象
 *
 * @return JSON字符串
 */
+ (NSString *)objectToJsonString:(id)object;

/**
 * JSON字符串转NSDictionary、NSArray
 *
 * @param jsonString JSON字符串
 *
 * @return NSDictionary、NSArray对象
 */
+ (nullable id)jsonStringToObject:(NSString *)jsonString;

/**
 * 根据约定的命名空间来解析JS调用的实例与方法，
 * 如，“xx”命名空间对应的实例类是XXBridge，要调用该类的-(void)method方法，JS端调用“xx.method”即可
 *
 * @param callString 含命名空间的方法调用
 * @param methodName 解析出来的方法名
 *
 * @return 解析出来的命名空间
 */
+ (NSString *)interfaceNamespaceWithCallString:(NSString *)callString
                                    methodName:(NSString **)methodName;

/**
 * 字符串编码
 */
+ (NSString *)stringByURLEncodeWithString:(NSString *)string;

/**
 * 源自ibireme的 YYKit
 *
 * 执行任意实例对象的任意方法
 *
 * @param object    消息的对象
 * @param sel           要执行的SEL
 * @param ...           可变参数列表，对应SEL的参数列表，
 *                不支持大于256 byte的联合体(union)和结构体(struct)
 * @return        方法执行的返回值
 *
 * @discussion    非对象类型的返回值将会包装成NSNumber或者NSValue，
 *                void类型返回值将会返回nil
 *
 */
+ (id)performSelectorForObject:(id)object withArgs:(SEL)sel, ...;

@end

NS_ASSUME_NONNULL_END
