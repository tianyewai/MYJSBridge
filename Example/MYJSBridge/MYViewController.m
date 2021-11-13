//
//  MYViewController.m
//  MYJSBridge
//
//  Created by tianyewai on 11/13/2021.
//  Copyright (c) 2021 tianyewai. All rights reserved.
//

#import "MYViewController.h"

#import "TestBridge+Common.h"
#import <MYJSBridge/MYJSBridge.h>

@interface MYViewController ()<WKUIDelegate>

@property (nonatomic, strong) MYWKWebView *webView;
@end

@implementation MYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.webView = [[MYWKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.webView.MYUIDelegate = self;
    TestBridge *bridge = [[TestBridge alloc] init];
    [self.webView addJavascriptObject:bridge forNamespace:nil];

    NSString *basePath = [[NSBundle mainBundle] pathForResource:@"testApp" ofType:@""];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"testApp/native" ofType:@"html"];
    [self.webView loadFilePath:path basePath:basePath];

    [self.view addSubview:self.webView];
}

#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(void))completionHandler
{
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:@"提示"
                               message:message
                              delegate:self
                     cancelButtonTitle:@"确定"
                     otherButtonTitles:nil,nil];
    [alertView show];

    completionHandler();
}

@end
