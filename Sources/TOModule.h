@import UIKit;

NS_ASSUME_NONNULL_BEGIN

/// 模块子类必须遵守此APP生命周期协议
@protocol TOModuleApplicationProtocol <UIApplicationDelegate>
@end

/// 业务事件协议, 模块子类可以选择性遵守
@class TOModuleEventItem;
@protocol TOModuleEventProtocol <NSObject>

/** 接收到来自其他模块的组件消息 */
- (void)moduleDidReceivedBroadcastEvent:(TOModuleEventItem *)eventItem;
@end

/**
   模块优先级
   - TOModulePriorityVeryLow: 极底
   - TOModulePriorityLow: 低 安排给弱业务，业务模块
   - TOModulePriorityMedium: 中
   - TOModulePriorityHigh: 高
   - TOModulePriorityVeryHigh: 极高 安排给基础模块（有些基础模块每次依赖都需要手动调用初始化方法，建议分成 Core / Initializer subspec，后者中只有一个类继承TOModule，这样直接依赖模块时，初始化代码的编写就可以去掉了）这种情况下，TOModule子类中，最好不要存在硬编码，使用变量或配置文件配置，这样才能让各业务线通用
 */
typedef NS_ENUM(NSInteger, TOModulePriority) {
    TOModulePriorityVeryLow  = 25,
    TOModulePriorityLow      = 50,
    TOModulePriorityMedium   = 100,
    TOModulePriorityHigh     = 150,
    TOModulePriorityVeryHigh = 175,
} NS_SWIFT_NAME(TOModulePriority);

/// 模块事件实体,可以进行跨模块消息通讯,例如账号登录,退出事件
typedef void (^TOModuleEventCallback)(TOModuleEventItem *event);
@interface TOModuleEventItem : NSObject
/// 事件名称
@property (nonatomic, strong, readonly) NSString *name;
/// 事件附带的自定义数据
@property (nullable, nonatomic, strong, readonly) NSDictionary *userInfo;
/// 事件回调,一些事件需要接收者发出响应回调,可以通过该参数进行回调数据
@property (nullable, nonatomic, copy) TOModuleEventCallback callback;

/// 构造一个事件
/// - Parameter name: 事件名
+ (instancetype)makeEvent:(NSString *)name;

/// 构造一个事件
/// - Parameters:
///   - name: 事件名
///   - userInfo: 自定义数据
+ (instancetype)makeEvent:(NSString *)name userInfo:(nullable NSDictionary *)userInfo;

@end

@interface TOModule : NSObject

+ (instancetype)module;

/**在 load 中调用，以注册模块 */
+ (void)registerModule;

/**
   模块优先级

   主工程模块的调用最先进行，剩余附属模块，
   内部会根据优先级，依次调用 UIApplicationDelegate 代理
   默认是 TOModulePriorityMedium

   @return 优先级
 */
+ (TOModulePriority)priority;

/**
   在调用方法执行完成之后执行 block

   - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self runAfterMethodExecuted:^{
        // 创建 windows
    }];
    return YES;
   }

   某些操作只能在系统声明周期执行完成之后才执行，比如创建 level 比较高的 window，需要设置 root vc，（可能会和原 root vc 冲突）
   这时候就需要将操作放入下面 block 中

   推荐对顺序不敏感，对系统调用返回值不影响的操作都放在这个方法的 block 参数中
 */
- (void)runAfterMethodExecuted:(void (^)(void))block;

/** 向整个工程模块组件发出一个广播消息  */
+ (void)sendoutBroadcastEvent:(TOModuleEventItem *)event;

@end

NS_ASSUME_NONNULL_END
