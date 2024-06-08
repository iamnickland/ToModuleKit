//
//  ViewController.m
//  ModuleExample
//
//  Created by Nick Land on 2024/6/8.
//

#import "ViewController.h"
#import "TModuleA.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSLog(@"resultA %d", [[UIApplication sharedApplication].delegate application:[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ftp://ggboy"] options:@{}]);
    NSLog(@"resultB %d", [[UIApplication sharedApplication].delegate application:[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://ggboy"] options:@{}]);

    NSLog(@"resultC %d", [[UIApplication sharedApplication].delegate application:[UIApplication sharedApplication] shouldAllowExtensionPointIdentifier:@"LALALA"]);
    // Do any additional setup after loading the view, typically from a nib.

//    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        @strongify(self);

        TOModuleEventItem *event = [TOModuleEventItem makeEvent:@"login" userInfo:@{ @"type": @(1) }];
        [TModuleA sendoutBroadcastEvent:event];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        @strongify(self);

        TOModuleEventItem *event = [TOModuleEventItem makeEvent:@"getOrderId"];
        event.callback = ^(TOModuleEventItem *_Nonnull event) {
            NSLog(@"callback: %@:%@", event.name, event.userInfo);
        };
        [TModuleA sendoutBroadcastEvent:event];
    });
}

@end
