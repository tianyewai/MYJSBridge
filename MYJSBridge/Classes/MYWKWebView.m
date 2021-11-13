//
//  MYWKWebView.m
//
//  Created by tianyewai on 2021/11/8.
//

#import "MYWKWebView.h"
#import "MYWKUIDelegate.h"
#import "MYJSBUtil.h"

#ifndef dispatch_main_queue_async
#define dispatch_main_queue_async(block)\
        if ([NSThread isMainThread]) {\
            block();\
        } else {\
            dispatch_async(dispatch_get_main_queue(), block);\
        }
#endif

@interface MYWKWebView ()

// UIDelegate代理
@property (nonatomic, strong) MYWKUIDelegate *webUIDelegate;

@end

@implementation MYWKWebView

- (void)dealloc
{
#if DEBUG
    NSLog(@"%s", __func__);
#endif
}

-(instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration
{
    WKUserScript *script = [[WKUserScript alloc] initWithSource:MYJSBInitCode
                                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                               forMainFrameOnly:YES];
    [configuration.userContentController addUserScript:script];

    self = [super initWithFrame:frame configuration: configuration];
    if (self) {
        self.webUIDelegate = [[MYWKUIDelegate alloc] init];
        self.UIDelegate = self.webUIDelegate;
    }

    return self;
}

- (void)setMYUIDelegate:(id<WKUIDelegate>)MYUIDelegate
{
    _MYUIDelegate = MYUIDelegate;
    self.webUIDelegate.delegate = MYUIDelegate;
}

- (void)addJavascriptObject:(id)object forNamespace:(nullable NSString *)np
{
    [self.webUIDelegate.JSBCore addJavascriptObject:object forNamespace:np];
}

- (void)removeJavascriptObjectForNamespace:(NSString *)np
{
    [self.webUIDelegate.JSBCore removeJavascriptObjectForNamespace:np];
}

- (void)safeEvaluateJS:(NSString *)javaScriptString
{
    [self safeEvaluateJS:javaScriptString completion:nil];
}

- (void)safeEvaluateJS:(NSString *)javaScriptString completion:(void (^ _Nullable)(_Nullable id result, NSError * _Nullable error))completion
{
    void(^evaluateBlock)(void) = ^{
        if (!javaScriptString) {
            if (completion) completion(nil, nil);
            return;
        }

        [self evaluateJavaScript:javaScriptString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            dispatch_main_queue_async(^{
                if (completion) completion(result, error);
            });
        }];
    };

    dispatch_main_queue_async(evaluateBlock);
}

- (nullable WKNavigation *)loadURL:(NSString *)URL
{
    if (!URL) return nil;

    return [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];
}

- (nullable WKNavigation *)loadFilePath:(NSString *)path basePath:(NSString *)basePath
{
    if (!path) return nil;
    if (!basePath) basePath = path;

    NSURL *URL     = [NSURL fileURLWithPath:path];
    NSURL *baseURL = [NSURL fileURLWithPath:basePath];

    return [self loadFileURL:URL allowingReadAccessToURL:baseURL];
}

@end
