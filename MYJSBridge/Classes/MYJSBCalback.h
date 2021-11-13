//
//  MYJSBCalback.h
//
//  Created by tianyewai on 2021/11/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * JS异步调用的回调
 */
@interface MYJSBCalback : NSObject

/**
 * 初始化回调对象
 *
 * @param jsMethodName js的回调的标识
 * @param didCallbackBlock 回调block，交给网页执行JS回调代码
 *
 * @return 对象
 */
- (instancetype)initWithJSMethodName:(NSString *)jsMethodName
                    didCallbackBlock:(void(^)(NSString *jsCode))didCallbackBlock;

/**
 * 执行回调
 */
- (void)callback;

/**
 * 执行回调，并结束
 *
 * @param value 回调的值，需要支持JSON序列化
 */
- (void)callbackWithValue:(nullable id)value;

/**
 * 执行回调
 *
 * @param value 回调的值，需要支持JSON序列化
 * @param completed 是否结束
 *
 */
- (void)callbackWithValue:(nullable id)value completed:(BOOL)completed;

/**
 * 执行回调
 *
 * @param code code
 * @param value 回调的值，需要支持JSON序列化
 * @param completed 是否结束
 *
 */
- (void)callbackWithCode:(NSInteger)code value:(nullable id)value completed:(BOOL)completed;

@end

NS_ASSUME_NONNULL_END
