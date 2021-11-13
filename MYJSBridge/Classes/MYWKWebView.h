//
//  MYWKWebView.h
//
//  Created by tianyewai on 2021/11/8.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @note 支持两种方式的原生与JS交互：同步、异步
 *
 * 使用者通过设置交互接口对象（实现了JS要调用的方法）来实现原生的调用并可进行异步调用:
 * - addJavascriptObject:forNamespace:
 *
 * 对于接口对象：
 * JS的异步调用，其方法实现不能超过两个参数，第二个参数的签名必须是MYJSBAsynMethodCallbackHandler
 * 并且第二个参数必须是MYJSBCalback的实例，格式如：-methodWithParams:callback:
 * JS的同步调用，其方法实现不能超过一个参数
 *
 * @warning 设置MYUIDelegate来替换设置UIDelegate，
 *          交互接口方法不要以NSObject的方法来命名（防止开发者未实现时调用异常）
 */
@interface MYWKWebView : WKWebView

/**
 * 替换了 UIDelegate，设置该属性来实现代理（不可以直接设置UIDelegate）
 */
@property (nullable, nonatomic, weak) id <WKUIDelegate> MYUIDelegate;

/**
 * 添加实现JS调用的原生方法的对象
 *
 * @param object 原生对象，需要实现JS的调用方法，不要以NSObject的方法来命名（防止开发者未实现时调用异常）
 * @param np          命名空间，命名空间与对象形成映射，如命名空间"login"可以对应类"MYLoginBridge"的对象
 *              那么JS端call "login.doSomething"就是如原生[MYLoginBridge实例 doSomething]的调用
 *              np如果是nil，默认会设置为@""的命名空间
 * @discussion  JS的异步调用，在object中的方法，其实现不能超过两个参数，第二个参数的签名必须是MYJSBAsynMethodCallbackHandler，
 *              并且第二个参数必须是MYJSBCalback的实例，格式如：-methodWithParams:callback:
 *              JS的同步调用，在object中的方法，其实现不能超过一个参数
 */
- (void)addJavascriptObject:(id)object forNamespace:(nullable NSString *)np;

/**
 * 删除JS调用原生方法的对象
 *
 * @param np  命名空间
 */
- (void)removeJavascriptObjectForNamespace:(NSString *)np;

/**
 * 执行一段JS，主线程
 *
 * @param javaScriptString  JS串
 */
- (void)safeEvaluateJS:(NSString *)javaScriptString;

/**
 * 执行一段JS，主线程
 *
 * @param javaScriptString  JS串
 * @param completion 执行结果回调（主线程）
 */
- (void)safeEvaluateJS:(NSString *)javaScriptString completion:(void (^ _Nullable)(_Nullable id result, NSError * _Nullable error))completion;

/**
 * 加载网络资源
 *
 * @param URL 网络地址
 *
 * @return WKNavigation
 */
- (nullable WKNavigation *)loadURL:(NSString *)URL;

/**
 * 加载本地资源
 *
 * @param path          本地资源路径
 * @param basePath  webKit可访问的目录或者路径
 *
 * @return WKNavigation
 */
- (nullable WKNavigation *)loadFilePath:(NSString *)path basePath:(NSString *)basePath;

@end

NS_ASSUME_NONNULL_END
