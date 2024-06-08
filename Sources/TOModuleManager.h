@import Foundation;
#import "TOModule.h"

NS_ASSUME_NONNULL_BEGIN

@class TOModule;
@interface TOApplicationDelegateProxy : NSObject
@property (nullable, nonatomic, strong) id <TOModuleApplicationProtocol> realDelegate;
@end

@interface TOModuleManager : NSObject
{
    @package TOApplicationDelegateProxy *_proxy;
}
@property (nonatomic, strong, readonly) TOApplicationDelegateProxy *proxy;
@property (nonatomic, strong, readonly) NSArray <TOModule *> *modules;

+ (instancetype)shared;
+ (void)addModuleClass:(Class)cls;
+ (void)removeModuleClass:(Class)cls;
+ (void)sendoutBroadcastEvent:(TOModuleEventItem *)event;
@end

NS_ASSUME_NONNULL_END
