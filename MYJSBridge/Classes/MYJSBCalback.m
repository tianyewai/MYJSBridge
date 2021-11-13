//
//  MYJSBCalback.m
//
//  Created by tianyewai on 2021/11/9.
//

#import "MYJSBCalback.h"
#import "MYJSBUtil.h"

@interface MYJSBCalback ()

@property (nonatomic, copy) NSString *jsMethodName;
@property (nonatomic, copy) void(^didCallbackBlock)(NSString *jsCode);

@end

@implementation MYJSBCalback

- (void)dealloc
{
#if DEBUG
NSLog(@"%s", __func__);
#endif
}

- (instancetype)initWithJSMethodName:(NSString *)jsMethodName
                    didCallbackBlock:(void(^)(NSString *jsCode))didCallbackBlock
{
    self = [super init];
    if (self) {
        self.jsMethodName = jsMethodName;
        self.didCallbackBlock = didCallbackBlock;
    }

    return self;
}

- (void)callback
{
    [self callbackWithValue:nil];
}

- (void)callbackWithValue:(nullable id)value
{
    [self callbackWithValue:value completed:YES];
}

- (void)callbackWithValue:(nullable id)value completed:(BOOL)completed
{
    [self callbackWithCode:MYJSBCallSucceedCode value:value completed:completed];
}

- (void)callbackWithCode:(NSInteger)code value:(nullable id)value completed:(BOOL)completed
{
    NSMutableDictionary *result = @{MYJSBArgsCodeKey : @(code),
                                    MYJSBArgsDataKey : @""}.mutableCopy;

    result[MYJSBArgsDataKey] = value ? value : [NSNull null];

    // 回调给JS的参数
    NSString *jsCallbacArg = [MYJSBUtil objectToJsonString:result];
    jsCallbacArg = [MYJSBUtil stringByURLEncodeWithString:jsCallbacArg];

    // 完整的JS执行代码
    NSString *jsCode = [self jsCallbackWithMethod:self.jsMethodName
                                           jsArgv:jsCallbacArg
                                     deleteMethod:completed];

    if (self.didCallbackBlock) {
        self.didCallbackBlock(jsCode);
        if (completed) {
            self.didCallbackBlock = nil;
        }
    }
}

/**
 * 异步的JS回调，组装完整的JS回调代码
 *
 * @param jsMethod js的回调方法
 * @param argv 回调参数
 * @param delete 回调后是否删除window中的js
 *
 * @return JS回调代码
 */
- (NSString *)jsCallbackWithMethod:(NSString *)jsMethod
                            jsArgv:(NSString *)argv
                      deleteMethod:(BOOL)delete
{
    // 完成后删除JS的回调
    NSString *deleteJSCallback = delete ? [@"delete window." stringByAppendingString:jsMethod] : @"";

    // JS回调的执行代码
    NSString *executingJSCode = [NSString stringWithFormat:@"try {%@(JSON.parse(decodeURIComponent(\"%@\")).%@);%@; } catch(e){};",jsMethod,
                                 argv,
                                 MYJSBArgsDataKey,
                                 deleteJSCallback];

    return executingJSCode;
}

@end
