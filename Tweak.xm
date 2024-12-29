// Tweak.xm
// 作者 pxx

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <substrate.h>

// 辅助函数：获取当前顶层视图控制器
static UIViewController* topViewController(UIViewController *rootViewController) {
    if (rootViewController.presentedViewController) {
        return topViewController(rootViewController.presentedViewController);
    }
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)rootViewController;
        return topViewController(nav.topViewController);
    }
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)rootViewController;
        return topViewController(tab.selectedViewController);
    }
    return rootViewController;
}

%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    
    // 使用静态变量确保弹窗只显示一次
    static BOOL alertShown = NO;
    if (alertShown) {
        return;
    }
    alertShown = YES;
    
    // 创建自定义弹窗
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"水君"
                                                                   message:@"水君 牛逼"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    // 不同意按钮
    UIAlertAction *disagreeAction = [UIAlertAction actionWithTitle:@"不同意"
                                                             style:UIAlertActionStyleCancel
                                                           handler:^(UIAlertAction * _Nonnull action) {
        // 用户点击了“不同意”，强制应用闪退
        NSLog(@"用户点击了不同意按钮，应用将退出。");
        abort(); // 强制应用闪退
    }];
    
    // 是的按钮
    UIAlertAction *agreeAction = [UIAlertAction actionWithTitle:@"是的"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
        // 用户点击了“是的”，可以添加其他逻辑
        NSLog(@"用户点击了是的按钮");
    }];
    
    [alert addAction:disagreeAction];
    [alert addAction:agreeAction];
    
    // 获取 keyWindow
    UIWindow *keyWindow = nil;
    
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                keyWindow = windowScene.windows.firstObject;
                break;
            }
        }
    } else {
        keyWindow = [UIApplication sharedApplication].keyWindow;
    }
    
    // 获取顶层视图控制器并呈现弹窗
    if (keyWindow) {
        UIViewController *topVC = topViewController(keyWindow.rootViewController);
        if (topVC) {
            // 避免重复呈现弹窗
            if (topVC.presentedViewController == nil) {
                [topVC presentViewController:alert animated:YES completion:nil];
                NSLog(@"弹窗已显示");
            }
        } else {
            NSLog(@"未能找到顶层视图控制器");
        }
    } else {
        NSLog(@"未能找到 keyWindow");
    }
}

%end
