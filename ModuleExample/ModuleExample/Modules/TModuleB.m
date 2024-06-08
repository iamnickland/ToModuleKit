//
//  TModuleB.m
//  ModuleExample
//
//  Created by Nick Land on 2024/6/8.
//

#import "TModuleB.h"

@implementation TModuleB
+ (void)load {
    [self registerModule];
}

+ (TOModulePriority)priority {
    return TOModulePriorityHigh;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self runAfterMethodExecuted:^{
        NSLog(@"runAfterMethodExecuted %@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }];
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"%@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"%@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"%@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    NSLog(@"%@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return NO;
}

- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(UIApplicationExtensionPointIdentifier)extensionPointIdentifier {
    NSLog(@"%@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    return NO;
}

#pragma mark - TOModuleEventProtocol
- (void)moduleDidReceivedBroadcastEvent:(TOModuleEventItem *)eventItem {
    NSLog(@"%@,moduleDidReceivedBroadcastMessage:%@-%@", NSStringFromClass([self class]), eventItem.name, eventItem.userInfo);

    if ([eventItem.name isEqualToString:@"getOrderId"] && eventItem.callback) {
        eventItem.callback([TOModuleEventItem makeEvent:@"getOrderId" userInfo:@{ @"orderId": @(1000) }]);
    }
}

@end
