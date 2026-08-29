#import "AdSkipManager.h"

static const NSInteger kAdSkipHUDTag = 999888;

@implementation AdSkipManager

+ (instancetype)sharedManager {
    static AdSkipManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AdSkipManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _enabled = YES;
        _graceTime = 2.0;
        _minShowTime = 3.0;
        _showHUD = YES;
        _skipRewardVideo = YES;
        _skipInterstitial = YES;
        _skipSplash = YES;
        [self loadConfig];
    }
    return self;
}

- (void)loadConfig {
    // 从配置文件加载（如果存在）
    NSString *configPath = @"/var/mobile/Library/Preferences/com.adskip.tweak.plist";
    NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:configPath];
    if (config) {
        if (config[@"enabled"]) _enabled = [config[@"enabled"] boolValue];
        if (config[@"graceTime"]) _graceTime = [config[@"graceTime"] doubleValue];
        if (config[@"minShowTime"]) _minShowTime = [config[@"minShowTime"] doubleValue];
        if (config[@"showHUD"]) _showHUD = [config[@"showHUD"] boolValue];
        if (config[@"skipRewardVideo"]) _skipRewardVideo = [config[@"skipRewardVideo"] boolValue];
        if (config[@"skipInterstitial"]) _skipInterstitial = [config[@"skipInterstitial"] boolValue];
        if (config[@"skipSplash"]) _skipSplash = [config[@"skipSplash"] boolValue];
    }
}

#pragma mark - 核心：延迟触发回调

- (void)triggerCallbackOnTarget:(id)target
                        selector:(SEL)selector
                            args:(NSArray *)args
                      afterDelay:(NSTimeInterval)delay {
    if (!self.enabled || !target || !selector) return;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @try {
            NSMethodSignature *sig = [target methodSignatureForSelector:selector];
            if (!sig) {
                NSLog(@"[AdSkip] 方法签名不存在: %@", NSStringFromSelector(selector));
                return;
            }

            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
            invocation.target = target;
            invocation.selector = selector;

            // 设置参数（从索引2开始，0是target，1是selector）
            for (NSInteger i = 0; i < args.count && (i + 2) < sig.numberOfArguments; i++) {
                id arg = args[i];
                const char *type = [sig getArgumentTypeAtIndex:i+2];

                if ([arg isKindOfClass:[NSNumber class]]) {
                    NSNumber *num = (NSNumber *)arg;
                    if (strcmp(type, @encode(int)) == 0) {
                        int val = [num intValue];
                        [invocation setArgument:&val atIndex:i+2];
                    } else if (strcmp(type, @encode(NSInteger)) == 0) {
                        NSInteger val = [num integerValue];
                        [invocation setArgument:&val atIndex:i+2];
                    } else if (strcmp(type, @encode(float)) == 0) {
                        float val = [num floatValue];
                        [invocation setArgument:&val atIndex:i+2];
                    } else if (strcmp(type, @encode(double)) == 0) {
                        double val = [num doubleValue];
                        [invocation setArgument:&val atIndex:i+2];
                    } else if (strcmp(type, @encode(BOOL)) == 0) {
                        BOOL val = [num boolValue];
                        [invocation setArgument:&val atIndex:i+2];
                    } else if (strcmp(type, @encode(long long)) == 0) {
                        long long val = [num longLongValue];
                        [invocation setArgument:&val atIndex:i+2];
                    } else if (strcmp(type, @encode(NSTimeInterval)) == 0) {
                        NSTimeInterval val = [num doubleValue];
                        [invocation setArgument:&val atIndex:i+2];
                    } else {
                        [invocation setArgument:&arg atIndex:i+2];
                    }
                } else {
                    [invocation setArgument:&arg atIndex:i+2];
                }
            }

            [invocation invoke];
            NSLog(@"[AdSkip] 成功触发回调: %@", NSStringFromSelector(selector));
        } @catch (NSException *e) {
            NSLog(@"[AdSkip] 触发回调异常: %@", e);
        }
    });
}

#pragma mark - HUD 显示

- (void)showSkipHUDWithText:(NSString *)text {
    if (!self.showHUD) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window) return;

        UIView *existing = [window viewWithTag:kAdSkipHUDTag];
        if (existing) [existing removeFromSuperview];

        UIView *hud = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 50)];
        hud.center = CGPointMake(window.bounds.size.width / 2, window.bounds.size.height / 2);
        hud.backgroundColor = [UIColor colorWithWhite:0 alpha:0.85];
        hud.layer.cornerRadius = 12;
        hud.tag = kAdSkipHUDTag;
        hud.alpha = 0;

        UILabel *label = [[UILabel alloc] initWithFrame:hud.bounds];
        label.text = text ?: @"广告跳过中...";
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        [hud addSubview:label];

        [window addSubview:hud];

        [UIView animateWithDuration:0.25 animations:^{
            hud.alpha = 1;
        }];
    });
}

- (void)hideSkipHUD {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIView *hud = [window viewWithTag:kAdSkipHUDTag];
        if (hud) {
            [UIView animateWithDuration:0.25 animations:^{
                hud.alpha = 0;
            } completion:^(BOOL finished) {
                [hud removeFromSuperview];
            }];
        }
    });
}

#pragma mark - 广告检测

- (BOOL)isAdViewController:(UIViewController *)vc {
    if (!vc) return NO;
    NSString *className = NSStringFromClass([vc class]);

    // 常见广告 SDK 类名关键词
    NSArray *adKeywords = @[
        @"Ad", @"AD", @"Advert", @"Reward", @"Video", @"Interstitial",
        @"Splash", @"Sigmob", @"Pangle", @"CSJ", @"GDT", @"GDTViad",
        @"KSAd", @"BaiduAd", @"BDAd", @"TencentAd", @"Inspire",
        @"FullScreen", @"Express", @"NativeExpress", @"FeedAd"
    ];

    for (NSString *keyword in adKeywords) {
        if ([className containsString:keyword]) {
            return YES;
        }
    }

    // 检查类名是否以 Ad 开头或结尾
    if ([className hasPrefix:@"Ad"] || [className hasSuffix:@"Ad"] ||
        [className hasPrefix:@"AD"] || [className hasSuffix:@"AD"]) {
        return YES;
    }

    return NO;
}

- (void)dismissCurrentAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *topVC = [self topMostViewController];
        if (!topVC) return;

        // 尝试各种关闭方式
        if ([topVC respondsToSelector:@selector(close)]) {
            [topVC performSelector:@selector(close)];
            NSLog(@"[AdSkip] 调用 close 关闭广告");
        } else if ([topVC respondsToSelector:@selector(closeAd)]) {
            [topVC performSelector:@selector(closeAd)];
            NSLog(@"[AdSkip] 调用 closeAd 关闭广告");
        } else if ([topVC respondsToSelector:@selector(dismiss)]) {
            [topVC performSelector:@selector(dismiss)];
            NSLog(@"[AdSkip] 调用 dismiss 关闭广告");
        } else if (topVC.presentingViewController) {
            [topVC dismissViewControllerAnimated:YES completion:nil];
            NSLog(@"[AdSkip] dismissViewController 关闭广告");
        }

        [self hideSkipHUD];
    });
}

- (UIViewController *)topMostViewController {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window) return nil;

    UIViewController *vc = window.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }

    if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = [(UINavigationController *)vc visibleViewController];
    }

    return vc;
}

@end
