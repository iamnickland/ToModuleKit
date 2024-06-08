//
//  TModuleA.m
//  ModuleExample
//
//  Created by Nick Land on 2024/6/8.
//

#import "TModuleA.h"

@implementation TModuleA
+ (void)load {
    [self registerModule];
}

+ (TOModulePriority)priority {
    return TOModulePriorityVeryHigh;
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
}

@end
