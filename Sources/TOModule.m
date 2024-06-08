#import "TOModule.h"
#import "TOModuleManager.h"

@interface TOModuleEventItem ()
@property (nonatomic, strong) NSString *name;
@property (nullable, nonatomic, strong) NSDictionary *userInfo;
@end
@implementation TOModuleEventItem
+ (instancetype)makeEvent:(NSString *)name userInfo:(nullable NSDictionary *)userInfo {
    TOModuleEventItem *item = [[TOModuleEventItem alloc] init];

    item.name = name;
    item.userInfo = userInfo;
    return item;
}

+ (instancetype)makeEvent:(NSString *)name {
    return [TOModuleEventItem makeEvent:name userInfo:nil];
}

@end

@implementation TOModule
- (instancetype)init {
    if (self = [super init]) {
        if (![self conformsToProtocol:@protocol(TOModuleApplicationProtocol)]) {
            @throw [NSException exceptionWithName:@"TOModuleRegisterProgress" reason:@"subclass should confirm to <TOModuleProtocol>." userInfo:nil];
        }
    }

    return self;
}

+ (instancetype)module {
    return [[self alloc] init];
}

+ (void)registerModule {
    // https://developer.apple.com/documentation/objectivec/nsobject/1418815-load?preferredLanguage=occ
    // In a custom implementation of load you can therefore safely message other unrelated classes from the same image, but any load methods implemented by those classes may not have run yet.
    // load 之前，同一个 image 中的所有 class 都是已知的，所以可以调用
    [TOModuleManager addModuleClass:self];
}

+ (TOModulePriority)priority {
    return TOModulePriorityMedium;
}

- (void)runAfterMethodExecuted:(void (^)(void))block {
    // 当前代码执行完后，再执行 block 代码
    dispatch_async(dispatch_get_main_queue(), ^{
        !block ? : block();
    });
}

+ (void)sendoutBroadcastEvent:(TOModuleEventItem *)event {
    [TOModuleManager sendoutBroadcastEvent:event];
}

@end
