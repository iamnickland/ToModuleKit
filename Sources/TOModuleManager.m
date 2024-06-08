@import ObjectiveC.runtime;
@import UIKit;

#import "TOModuleManager.h"
#import "TOModule.h"

static void TOSwizzleInstanceMethod(Class cls, SEL originalSelector, Class targetCls, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(targetCls, swizzledSelector);
    BOOL didAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));

    if (didAddMethod) {
        class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark - TOApplicationDelegateProxy

@implementation TOApplicationDelegateProxy
- (Protocol *)targetProtocol {
    return @protocol(UIApplicationDelegate);
}

- (BOOL)isTargetProtocolMethod:(SEL)selector {
    unsigned int outCount = 0;
    struct objc_method_description *methodDescriptions = protocol_copyMethodDescriptionList([self targetProtocol], NO, YES, &outCount);

    for (int idx = 0; idx < outCount; idx++) {
        if (selector == methodDescriptions[idx].name) {
            free(methodDescriptions);
            return YES;
        }
    }

    free(methodDescriptions);

    return NO;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([self.realDelegate respondsToSelector:aSelector]) {
        return YES;
    }

    for (TOModule *module in [TOModuleManager shared].modules) {
        if ([self isTargetProtocolMethod:aSelector] && [module respondsToSelector:aSelector]) {
            return YES;
        }
    }

    return [super respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if (![self isTargetProtocolMethod:aSelector] && [self.realDelegate respondsToSelector:aSelector]) {
        return self.realDelegate;
    }

    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    struct objc_method_description methodDescription = protocol_getMethodDescription([self targetProtocol], aSelector, NO, YES);

    if (methodDescription.name == NULL && methodDescription.types == NULL) {
        return [[self class] instanceMethodSignatureForSelector:@selector(doNothing)];
    }

    return [NSMethodSignature signatureWithObjCTypes:methodDescription.types];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSMutableArray *allModules = [NSMutableArray arrayWithObjects:self.realDelegate, nil];

    [allModules addObjectsFromArray:[TOModuleManager shared].modules];

    // BOOL 型返回值做特殊 | 处理
    if (anInvocation.methodSignature.methodReturnType[0] == 'B') {
        BOOL realReturnValue = NO;

        for (TOModule *module in allModules) {
            if ([module respondsToSelector:anInvocation.selector]) {
                [anInvocation invokeWithTarget:module];

                BOOL returnValue = NO;
                [anInvocation getReturnValue:&returnValue];

                realReturnValue = returnValue || realReturnValue;
            }
        }

        [anInvocation setReturnValue:&realReturnValue];
    } else {
        for (TOModule *module in allModules) {
            if ([module respondsToSelector:anInvocation.selector]) {
                [anInvocation invokeWithTarget:module];
            }
        }
    }
}

- (void)doNothing {
}

@end

#pragma mark - TOModuleManager

static NSMutableArray const *TOModuleClassArray = nil;

@interface TOModuleManager ()
@property (nonatomic, strong) NSMutableArray <TOModule *> *mModules;
@end

@implementation TOModuleManager
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static TOModuleManager *singleton = nil;

    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });
    return singleton;
}

+ (void)addModuleClass:(Class)cls {
    NSParameterAssert(cls && [cls isSubclassOfClass:[TOModule class]]);

    if (!TOModuleClassArray) {
        TOModuleClassArray = [NSMutableArray array];
    }

    if (![TOModuleClassArray containsObject:cls]) {
        [TOModuleClassArray addObject:cls];
    }
}

+ (void)removeModuleClass:(Class)cls {
    [TOModuleClassArray removeObject:cls];
}

+ (void)sendoutBroadcastEvent:(TOModuleEventItem *)event {
    for (TOModule *module in [TOModuleManager shared].modules) {
        if ([module conformsToProtocol:@protocol(TOModuleEventProtocol) ]) {
            id<TOModuleEventProtocol> service = (id<TOModuleEventProtocol>)module;

            if ([service respondsToSelector:@selector(moduleDidReceivedBroadcastEvent:) ]) {
                [service moduleDidReceivedBroadcastEvent:event];
            }
        }
    }
}

#pragma mark - Private

- (void)generateRegistedModules {
    [self.mModules removeAllObjects];

    [TOModuleClassArray sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"priority" ascending:NO]]];

    for (Class cls in TOModuleClassArray) {
        TOModule *module = [cls module];
        NSAssert(module, @"module can't be nil of class %@", NSStringFromClass(cls));

        if (![self.mModules containsObject:module]) {
            [self.mModules addObject:module];
        }
    }
}

- (TOApplicationDelegateProxy *)proxy {
    if (!_proxy) {
        _proxy = [[TOApplicationDelegateProxy alloc] init];
    }

    return _proxy;
}

- (NSArray<TOModule *> *)modules {
    return (NSArray<TOModule *> *)self.mModules;
}

- (NSMutableArray<TOModule *> *)mModules {
    if (!_mModules) {
        _mModules = [NSMutableArray array];
    }

    return _mModules;
}

@end

@implementation UIApplication (TOModule)
+ (void)load {
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        TOSwizzleInstanceMethod(self, @selector(setDelegate:), self, @selector(to_setDelegate:));
    });
}

- (void)to_setDelegate:(id <TOModuleApplicationProtocol>)delegate {
    TOModuleManager.shared.proxy.realDelegate = delegate;
    [TOModuleManager.shared generateRegistedModules];

    [self to_setDelegate:(id <TOModuleApplicationProtocol>)TOModuleManager.shared.proxy];
}

@end
