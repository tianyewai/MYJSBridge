//
//  MYWKUIDelegate.m
//
//  Created by tianyewai on 2021/11/8.
//

#import "MYWKUIDelegate.h"
#import "MYJSBUtil.h"

@interface MYWKUIDelegate ()

@end

@implementation MYWKUIDelegate

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
        self.JSBCore = [[MYJSBridgeCore alloc] init];
    }
    return self;
}

- (void)webView:(WKWebView *)webView
runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
    defaultText:(nullable NSString *)defaultText
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(NSString * _Nullable result))completionHandler
{
    if ([prompt hasPrefix:MYJSBPromptPrefix]) {
        NSString *method = [prompt substringFromIndex:[MYJSBPromptPrefix length]];
        NSString *result = nil;

        @try {
            result = [self.JSBCore callMethod:method argumentify:defaultText webView:webView];
        }@catch(NSException *exception){
            MYJSBLog(@"%@", exception);
        }

        completionHandler(result);

        return;

    }
    
    if([self.delegate respondsToSelector:
        @selector(webView:
                  runJavaScriptTextInputPanelWithPrompt:
                  defaultText:
                  initiatedByFrame:
                  completionHandler:)]) {
        [self.delegate webView:webView
runJavaScriptTextInputPanelWithPrompt:prompt
                   defaultText:defaultText
              initiatedByFrame:frame
             completionHandler:completionHandler];
    } else {
        completionHandler(nil);
    }

}

- (nullable WKWebView *)webView:(WKWebView *)webView
 createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
            forNavigationAction:(WKNavigationAction *)navigationAction
                 windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if([self.delegate respondsToSelector:
        @selector(webView:
                  createWebViewWithConfiguration:
                  forNavigationAction:
                  windowFeatures:)]){
        return [self.delegate webView:webView
       createWebViewWithConfiguration:configuration
                  forNavigationAction:navigationAction
                       windowFeatures:windowFeatures];
    }

    return nil;
}

- (void)webViewDidClose:(WKWebView *)webView
{
    if([self.delegate respondsToSelector:@selector(webViewDidClose:)]) {
        [self.delegate webViewDidClose:webView];
    }
}

- (void)webView:(WKWebView *)webView
runJavaScriptAlertPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(void))completionHandler
{
    if([self.delegate respondsToSelector:
        @selector(webView:
                  runJavaScriptAlertPanelWithMessage:
                  initiatedByFrame:
                  completionHandler:)]) {
        [self.delegate webView:webView
runJavaScriptAlertPanelWithMessage:message
              initiatedByFrame:frame
             completionHandler:completionHandler];
    } else {
        completionHandler();
    }
}

- (void)webView:(WKWebView *)webView
runJavaScriptConfirmPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(BOOL result))completionHandler
{
    if([self.delegate respondsToSelector:
        @selector(webView:
                  runJavaScriptConfirmPanelWithMessage:
                  initiatedByFrame:
                  completionHandler:)]) {
        [self.delegate webView:webView
runJavaScriptConfirmPanelWithMessage:message
              initiatedByFrame:frame
             completionHandler:completionHandler];
    } else {
        completionHandler(YES);
    }
}

#ifdef __IPHONE_15_0

- (void)webView:(WKWebView *)webView
requestMediaCapturePermissionForOrigin:(WKSecurityOrigin *)origin
initiatedByFrame:(WKFrameInfo *)frame
           type:(WKMediaCaptureType)type
decisionHandler:(void (^)(WKPermissionDecision decision))decisionHandler API_AVAILABLE(macos(12.0), ios(15.0))
{
    if ([self.delegate respondsToSelector:
         @selector(webView:
                   requestMediaCapturePermissionForOrigin:
                   initiatedByFrame:
                   type:
                   decisionHandler:)]) {
        [self.delegate webView:webView
requestMediaCapturePermissionForOrigin:origin
              initiatedByFrame:frame
                          type:type
               decisionHandler:decisionHandler];
    } else {
        decisionHandler(WKPermissionDecisionDeny);
    }
}

- (void)webView:(WKWebView *)webView
requestDeviceOrientationAndMotionPermissionForOrigin:(WKSecurityOrigin *)origin
initiatedByFrame:(WKFrameInfo *)frame
decisionHandler:(void (^)(WKPermissionDecision decision))decisionHandler API_AVAILABLE(ios(15.0)) API_UNAVAILABLE(macos)
{
    if ([self.delegate respondsToSelector:
         @selector(webView:
                   requestDeviceOrientationAndMotionPermissionForOrigin:
                   initiatedByFrame:
                   decisionHandler:)]) {
        [self.delegate webView:webView
requestDeviceOrientationAndMotionPermissionForOrigin:origin
              initiatedByFrame:frame
               decisionHandler:decisionHandler];
    } else {
        decisionHandler(WKPermissionDecisionDeny);
    }
}

#endif

- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo
API_AVAILABLE(ios(10.0)) {
    if([self.delegate respondsToSelector:@selector(webView:shouldPreviewElement:)]) {
        if (@available(iOS 10.0, *)) {
            return [self.delegate webView:webView shouldPreviewElement:elementInfo];
        }
    }

    return NO;
}

- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController {
    if([self.delegate respondsToSelector:@selector(webView:commitPreviewingViewController:)]){
        if (@available(iOS 10.0, *)) {
            [self.delegate webView:webView commitPreviewingViewController:previewingViewController];
        }
    }
}

- (void)webView:(WKWebView *)webView
contextMenuConfigurationForElement:(WKContextMenuElementInfo *)elementInfo
completionHandler:(void (^)(UIContextMenuConfiguration * _Nullable configuration))completionHandler
API_AVAILABLE(ios(13.0))
{
    if ([self.delegate respondsToSelector:@selector(webView:contextMenuConfigurationForElement:completionHandler:)]) {
        [self.delegate webView:webView
contextMenuConfigurationForElement:elementInfo
             completionHandler:completionHandler];
    }
}

- (void)webView:(WKWebView *)webView contextMenuWillPresentForElement:(WKContextMenuElementInfo *)elementInfo API_AVAILABLE(ios(13.0))
{
    if ([self.delegate respondsToSelector:@selector(webView:contextMenuWillPresentForElement:)]) {
        [self.delegate webView:webView contextMenuWillPresentForElement:elementInfo];
    }
}

- (void)webView:(WKWebView *)webView
contextMenuForElement:(WKContextMenuElementInfo *)elementInfo
willCommitWithAnimator:(id <UIContextMenuInteractionCommitAnimating>)animator
API_AVAILABLE(ios(13.0))
{
    if ([self.delegate respondsToSelector:@selector(webView:contextMenuForElement:willCommitWithAnimator:)]) {
        [self.delegate webView:webView
         contextMenuForElement:elementInfo
        willCommitWithAnimator:animator];
    }
}

- (void)webView:(WKWebView *)webView contextMenuDidEndForElement:(WKContextMenuElementInfo *)elementInfo API_AVAILABLE(ios(13.0))
{
    if ([self.delegate respondsToSelector:@selector(webView:contextMenuDidEndForElement:)]) {
        [self.delegate webView:webView contextMenuDidEndForElement:elementInfo];
    }
}

@end
