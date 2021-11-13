//
//  TestBridge+Common.m
//  MYJSBridge_Example
//
//  Created by tianyewai on 2021/11/13.
//  Copyright © 2021 tianyewai. All rights reserved.
//

#import "TestBridge+Common.h"

#import <MYJSBridge/MYJSBridge.h>

@implementation TestBridge (Common)

- (void)setItem:(NSDictionary *)item
{
    if (![item isKindOfClass:NSDictionary.class]) return;

    NSString *key = item[@"key"];
    id value = item[@"value"];

    if (![key isKindOfClass:NSString.class]) return;
    if (![value conformsToProtocol:@protocol(NSCoding)]) return;

    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];

}

- (id)getItem:(NSString *)key
{

    if (![key isKindOfClass:NSString.class]) return nil;

    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)removeItem:(NSString *)key
{
    if (![key isKindOfClass:NSString.class]) return;

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

- (void)finish
{
    NSLog(@"%s", __func__);
}

- (NSString *)appversion
{
    NSLog(@"%s", __func__);
    return @"0.1.2";
}

- (void)appversionAsync:(id)dd callback:(MYJSBCalback *)callback
{
    NSLog(@"%s", __func__);
    [callback callbackWithValue:@"0.1.3"];
}

- (void)versionAsync:(MYJSBCalback *)callback
{
    NSLog(@"%s", __func__);
    [callback callbackWithValue:@"0.1.2"];
}

@end
