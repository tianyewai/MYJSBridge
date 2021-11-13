//
//  MYJSBridgeCore.h
//
//  Created by tianyewai on 2021/11/8.
//

#import <Foundation/Foundation.h>

@class WKWebView;

NS_ASSUME_NONNULL_BEGIN

/**
 * JS调用原生及处理回调的核心类
 */
@interface MYJSBridgeCore : NSObject

/**
 * 响应JS的方法调用
 *
 * @param callMethod     未解析的方法名可能是"命名空间.doSomething"、"doSomething"
 * @param argumentify   参数的JSON字符串形式
 * @param webView            当前加载的 webView
 *
 * @return 调用结果
 */
- (NSString *)callMethod:(NSString *)callMethod
             argumentify:(NSString *)argumentify
                 webView:(WKWebView *)webView;

/**
 * 添加实现JS调用的原生方法的对象
 *
 * @param object 原生对象，需要实现JS的调用方法，不要以NSObject的方法来命名（防止开发者未实现时调用异常）
 * @param np          命名空间，命名空间与对象形成映射，如命名空间"login"可以对应类"MYLoginBridge"的对象
 *              那么JS端call "login.doSomething"就是如原生[MYLoginBridge实例 doSomething]的调用
 *              np如果是nil，默认会设置为@""的命名空间
 * @discussion  JS的异步调用，在object中的方法，其实现不能超过两个参数，并且第二个参数的签名必须是MYJSBAsynMethodCallbackHandler，
 *              第二个参数必须是MYJSBCalback的实例，格式如：-methodWithParams:callback:
 *              JS的同步调用，在object中的方法，其实现不能超过一个参数
 */
- (void)addJavascriptObject:(id)object forNamespace:(nullable NSString *)np;

/**
 * 删除JS调用原生方法的对象
 *
 * @param np  命名空间
 */
- (void)removeJavascriptObjectForNamespace:(NSString *)np;

@end

NS_ASSUME_NONNULL_END
