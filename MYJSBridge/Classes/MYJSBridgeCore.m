//
//  MYJSBridgeCore.m
//
//  Created by tianyewai on 2021/11/8.
//

#import "MYJSBridgeCore.h"
#import "MYJSBUtil.h"
#import "MYJSBCalback.h"
#import <WebKit/WebKit.h>

@interface MYJSBridgeCore ()
{
    dispatch_semaphore_t _semaphore;
}
/**
 * 异步JS方法调用的回调处理，限制短时间频繁回调
 */
@property (nonatomic, strong) NSString *callbackJSCache;
@property (nonatomic, assign) UInt64 lastCallbackTime;
@property (nonatomic, assign) BOOL callbackPending;

// 设置JS方法调用的命名空间
@property (nonatomic, strong) NSMutableDictionary *jsNamespaceInterfaces;

@end

@implementation MYJSBridgeCore

- (void)dealloc
{
#if DEBUG
    NSLog(@"%s", __func__);
#endif
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _semaphore = dispatch_semaphore_create(1);
        
        self.callbackJSCache  = @"";
        self.lastCallbackTime = 0;
        self.callbackPending  = NO;

        self.jsNamespaceInterfaces = @{}.mutableCopy;
    }
    return self;
}

- (NSString *)callMethod:(NSString *)callMethod
             argumentify:(NSString *)argumentify
                 webView:(WKWebView *)webView
{
    NSString *methodName = callMethod;
    // 解析JS的调用实例
    id jsInterfaceObject = [self jsInterfaceObjectWithCallMethod:callMethod
                                                      methodName:&methodName];
    if (!jsInterfaceObject) {
        MYJSBLog(@"Js bridge  called, but can't find a corresponded JavascriptObject!");
        return MYJSBInvalidReturnString;
    }

    // 解析方法的调用参数及回调
    NSDictionary *args = [MYJSBUtil jsonStringToObject:argumentify];
    if (!args || ![args isKindOfClass:NSDictionary.class]) {
        MYJSBLog(@"Js bridge called with invalid args!");
        return MYJSBInvalidReturnString;
    }
    id parameters = [args[MYJSBArgsDataKey] isKindOfClass:NSNull.class] ? nil : args[MYJSBArgsDataKey];
    NSString *jsCallback = args[MYJSBArgsCallbackKey];
   
    // 异步调用
    if (jsCallback) {
        NSString *methodWithParams = [NSString stringWithFormat:@"%@:%@:", methodName, MYJSBAsynMethodCallbackHandler];
        NSString *methodNoParams   = [NSString stringWithFormat:@"%@:", methodName];
        SEL selectorWithParams = NSSelectorFromString(methodWithParams);
        SEL selectorNoParams   = NSSelectorFromString(methodNoParams);
        SEL selector = [jsInterfaceObject respondsToSelector:selectorWithParams] ? selectorWithParams : selectorNoParams;

        __weak typeof(self) weakSelf = self;
        __weak typeof(webView) weakWebView = webView;
        // 原生的回调对象
        MYJSBCalback *nativeCallback = [[MYJSBCalback alloc] initWithJSMethodName:jsCallback
                                                                 didCallbackBlock:^(NSString * _Nonnull jsCode) {
            __strong typeof(self) self = weakSelf;
            __strong typeof(webView) webView = weakWebView;
            [self dispatchJSCallback:jsCode webView:webView];
        }];

        NSString *errorMsg = nil;
        if ([NSObject respondsToSelector:selector] ||
            [NSObject instancesRespondToSelector:selector]) {
            errorMsg = @"Js bridge calling the system(iOS) method! Forbidden!!!";
        }

        if (![jsInterfaceObject respondsToSelector:selector]) {
            errorMsg = @"Js bridge called with unrecognized asyn method!";
        }

        if (errorMsg) {
            MYJSBLog(@"%@",errorMsg);
            [nativeCallback callbackWithCode:MYJSBInvalidCallCode value:nil completed:YES];
            return MYJSBInvalidReturnString;
        }

        // 执行原生的调用
        [self callWithObject:jsInterfaceObject
                    selector:selector
                  withParams:selector == selectorWithParams
                withCallback:YES
                      params:parameters
                    callback:nativeCallback];

        return MYJSBAsynCallingReturnString;
    }

    SEL selectorWithParams = NSSelectorFromString([NSString stringWithFormat:@"%@:", methodName]);
    SEL selectorNoParams   = NSSelectorFromString(methodName);
    SEL selector = [jsInterfaceObject respondsToSelector:selectorWithParams] ? selectorWithParams : selectorNoParams;

    if ([NSObject respondsToSelector:selector] ||
        [NSObject instancesRespondToSelector:selector]) {
        MYJSBLog(@"Js bridge calling the system(iOS) method! Forbidden!!!");
        return MYJSBInvalidReturnString;
    }

    if ([jsInterfaceObject respondsToSelector:selector]) {
        NSMutableDictionary *result = MYJSBSucceedReturnObject.mutableCopy;

        id value =  [self callWithObject:jsInterfaceObject
                                selector:selector
                              withParams:selector == selectorWithParams
                            withCallback:NO
                                  params:parameters
                                callback:nil];

        result[MYJSBArgsDataKey] = value ? value : [NSNull null];

        return [MYJSBUtil objectToJsonString:result];
    }

    // 无法响应
    return MYJSBInvalidReturnString;
}

/**
 * 调用原生
 */
- (id)callWithObject:(id)object
            selector:(SEL)selector
          withParams:(BOOL)withParams
        withCallback:(BOOL)withCallback
              params:(id)params
            callback:(MYJSBCalback *)callback
{
    if (!object || !selector) return nil;

    if (withCallback) {
        if (withParams) {
            return [MYJSBUtil performSelectorForObject:object
                                              withArgs:selector, params, callback];
        }
        return [MYJSBUtil performSelectorForObject:object
                                          withArgs:selector, callback];
    }

    if (withParams) {
        return [MYJSBUtil performSelectorForObject:object
                                          withArgs:selector, params];
    }
    return [MYJSBUtil performSelectorForObject:object
                                      withArgs:selector];
}

/**
 * 获取JS的调用实例
 */
- (id)jsInterfaceObjectWithCallMethod:(NSString *)callMethod methodName:(NSString **)methodName
{
    NSString *interfaceNamespace = [MYJSBUtil interfaceNamespaceWithCallString:callMethod methodName:methodName];

    return self.jsNamespaceInterfaces[interfaceNamespace];
}

/**
 * 执行JS回调代码
 */
- (void)dispatchJSCallback:(NSString *)jsCode webView:(WKWebView *)webView
{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);

    UInt64 t = [[NSDate date] timeIntervalSince1970] * 1000;

    self.callbackJSCache = [self.callbackJSCache stringByAppendingString:jsCode];

    if(t - self.lastCallbackTime < 50) {
        if(!self.callbackPending) {
            [self dispatchJSCallbackAfterDelay:50 webView:webView];
            self.callbackPending = YES;
        }
    } else {
        [self dispatchJSCallbackAfterDelay:0 webView:webView];
    }
    dispatch_semaphore_signal(_semaphore);
}

- (void)dispatchJSCallbackAfterDelay:(UInt64)delay webView:(WKWebView *)webView
{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        __strong typeof(self) self = weakSelf;

        dispatch_semaphore_wait(self->_semaphore, DISPATCH_TIME_FOREVER);

        if([self.callbackJSCache length] != 0) {
            [webView evaluateJavaScript:self.callbackJSCache completionHandler:nil];
            self.callbackPending  = NO;
            self.callbackJSCache  = @"";
            self.lastCallbackTime = [[NSDate date] timeIntervalSince1970] * 1000;
        }

        dispatch_semaphore_signal(self->_semaphore);
    });
}

- (void)addJavascriptObject:(id)object forNamespace:(nullable NSString *)np
{
    if(np == nil) np = @"";

    if(object) [self.jsNamespaceInterfaces setObject:object forKey:np];
}

- (void)removeJavascriptObjectForNamespace:(NSString *)np
{
    if(np == nil) np = @"";

    [self.jsNamespaceInterfaces removeObjectForKey:np];
}

@end
