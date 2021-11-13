//
//  MYWKUIDelegate.h
//
//  Created by tianyewai on 2021/11/8.
//

#import <WebKit/WebKit.h>

#import "MYJSBridgeCore.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * WKUIDelegate的代理类，作用：
 * 1. 拦截约定条件下(JS的原生请求)的prompt的代理，调用原生代码；
 * 2. 转发其他代理给delegate对象以方便外部的实现；
 */
@interface MYWKUIDelegate : NSObject<WKUIDelegate>

/**
 * 由外部实现的UIDelegate代理
 */
@property (nullable, nonatomic, weak) id<WKUIDelegate> delegate;

/**
 * JS调原生的核心对象
 */
@property (nonatomic, strong) MYJSBridgeCore *JSBCore;

@end

NS_ASSUME_NONNULL_END
