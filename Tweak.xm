#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdSkipManager.h"

#define AdSkip [AdSkipManager sharedManager]

#pragma mark - 通用广告页面检测与自动跳过

%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;

    if (!AdSkip.enabled) return;

    // 检测是否是广告页面
    if ([AdSkip isAdViewController:self]) {
        NSString *className = NSStringFromClass([self class]);
        NSLog(@"[AdSkip] 检测到广告页面: %@", className);

        // 显示进度框
        [AdSkip showSkipHUDWithText:@"广告跳过中..."];

        // 宽限时间后尝试关闭广告
        NSTimeInterval delay = AdSkip.graceTime;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 先尝试调用广告 SDK 的关闭/完成回调
            [self tryTriggerAdCallbacks];

            // 再尝试直接关闭页面
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [AdSkip dismissCurrentAd];
            });
        });
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    %orig;
    [AdSkip hideSkipHUD];
}

%new
- (void)tryTriggerAdCallbacks {
    // 尝试调用常见的广告完成/关闭回调（基于 adsspeed 分析的方法名模式）
    NSArray *callbackSelectors = @[
        NSStringFromSelector(@selector(onStateAdClosed:adUnitID:watchedTime:effectiveTime:duration:viewID:)),
        NSStringFromSelector(@selector(onAdInspireSuccessForClose:)),
        NSStringFromSelector(@selector(close)),
        NSStringFromSelector(@selector(closeAd)),
        NSStringFromSelector(@selector(dismiss)),
        NSStringFromSelector(@selector(onAdClose)),
        NSStringFromSelector(@selector(onAdDismiss)),
        NSStringFromSelector(@selector(onRewardAdClose)),
        NSStringFromSelector(@selector(onRewardVerify)),
        NSStringFromSelector(@selector(rewardVideoAdDidClose:)),
        NSStringFromSelector(@selector(rewardVideoAdClientAdClose:)),
        NSStringFromSelector(@selector(interstitialAdDidClose:)),
        NSStringFromSelector(@selector(splashAdDidClose:)),
    ];

    for (NSString *selName in callbackSelectors) {
        SEL sel = NSSelectorFromString(selName);
        if ([self respondsToSelector:sel]) {
            NSLog(@"[AdSkip] 尝试触发回调: %@", selName);

            // 对于特定的广告关闭回调，构造参数（伪造观看完成）
            if ([selName containsString:@"onStateAdClosed"]) {
                // 参数: state, adUnitID, watchedTime, effectiveTime, duration, viewID
                NSArray *args = @[
                    @(1),                    // state: 关闭
                    @"",                     // adUnitID
                    @(999.0),                // watchedTime: 伪造观看时长（很大）
                    @(999.0),                // effectiveTime: 有效观看时长
                    @(999.0),                // duration: 总时长
                    @""                      // viewID
                ];
                [AdSkip triggerCallbackOnTarget:self selector:sel args:args afterDelay:0];
            } else if ([selName containsString:@"onAdInspireSuccessForClose"]) {
                // 激励成功回调
                NSArray *args = @[@""];
                [AdSkip triggerCallbackOnTarget:self selector:sel args:args afterDelay:0];
            } else {
                // 无参数方法直接调用
                [AdSkip triggerCallbackOnTarget:self selector:sel args:@[] afterDelay:0];
            }
            break; // 只触发第一个匹配的回调
        }
    }
}

%end

#pragma mark - 广告 SDK 特定 hook（基于 adsspeed 分析的方法名）

%group AdSDKSpecificHooks

// hook 广告展示方法，在广告展示时启动跳过逻辑
%hook NSObject

// 通用的广告展示回调 hook
- (void)onAdShow:(id)arg1 {
    %orig;
    if (AdSkip.enabled) {
        NSLog(@"[AdSkip] 检测到广告展示: onAdShow");
        [AdSkip showSkipHUDWithText:@"广告跳过中..."];
        [self performSkipAfterGrace];
    }
}

- (void)onAdLoaded:(id)arg1 {
    %orig;
    NSLog(@"[AdSkip] 广告加载完成: onAdLoaded");
}

- (void)onAdExposed:(id)arg1 {
    %orig;
    if (AdSkip.enabled) {
        NSLog(@"[AdSkip] 检测到广告曝光: onAdExposed");
        [AdSkip showSkipHUDWithText:@"广告跳过中..."];
        [self performSkipAfterGrace];
    }
}

%new
- (void)performSkipAfterGrace {
    NSTimeInterval delay = AdSkip.graceTime;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 尝试触发广告完成回调
        NSArray *closeSelectors = @[
            @"onStateAdClosed:adUnitID:watchedTime:effectiveTime:duration:viewID:",
            @"onAdInspireSuccessForClose:",
            @"onAdClose:",
            @"onAdDismiss:",
            @"close",
            @"dismiss"
        ];

        for (NSString *selName in closeSelectors) {
            SEL sel = NSSelectorFromString(selName);
            if ([self respondsToSelector:sel]) {
                NSLog(@"[AdSkip] 触发广告关闭回调: %@", selName);
                if ([selName containsString:@"onStateAdClosed"]) {
                    NSArray *args = @[@(1), @"", @(999.0), @(999.0), @(999.0), @""];
                    [AdSkip triggerCallbackOnTarget:self selector:sel args:args afterDelay:0];
                } else {
                    [AdSkip triggerCallbackOnTarget:self selector:sel args:@[] afterDelay:0];
                }
                break;
            }
        }

        // 延迟后隐藏 HUD
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [AdSkip hideSkipHUD];
        });
    });
}

%end

%end

#pragma mark - 构造函数

%ctor {
    @autoreleasepool {
        // 初始化管理器
        AdSkipManager *mgr = [AdSkipManager sharedManager];

        // 启用所有 hook group
        %init(_ungrouped);
        %init(AdSDKSpecificHooks);

        // 监听配置变更
        [[NSNotificationCenter defaultCenter] addObserverForName:@"AdSkipConfigChanged"
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
            NSLog(@"[AdSkip] 配置已变更，重新加载");
            [mgr loadConfig];
        }];

        NSLog(@"[AdSkipTweak] 已加载 v1.0.0");
        NSLog(@"[AdSkipTweak] 启用状态: %d", mgr.enabled);
        NSLog(@"[AdSkipTweak] 宽限时间: %.1fs", mgr.graceTime);
        NSLog(@"[AdSkipTweak] 最小展示时间: %.1fs", mgr.minShowTime);
        NSLog(@"[AdSkipTweak] 跳过激励视频: %d", mgr.skipRewardVideo);
        NSLog(@"[AdSkipTweak] 跳过插屏: %d", mgr.skipInterstitial);
        NSLog(@"[AdSkipTweak] 跳过开屏: %d", mgr.skipSplash);
    }
}
