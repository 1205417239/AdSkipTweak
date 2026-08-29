#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <substrate.h>

#define LOG_FILE @"/tmp/adskip_log.txt"

#pragma mark - 全局状态

static BOOL g_A_enabled = YES;
static BOOL g_C_enabled = YES;
static float g_speed_multiplier = 600.0f;
static BOOL g_C_triggered = NO;

#pragma mark - B方案：磁盘日志

void writeLog(NSString *msg) {
    @autoreleasepool {
        NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:LOG_FILE];
        if (!fh) {
            [[NSFileManager defaultManager] createFileAtPath:LOG_FILE contents:nil attributes:nil];
            fh = [NSFileHandle fileHandleForWritingAtPath:LOG_FILE];
        }
        if (fh) {
            [fh seekToEndOfFile];
            NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
            fmt.dateFormat = @"HH:mm:ss.SSS";
            NSString *line = [NSString stringWithFormat:@"[%@] %@\n", [fmt stringFromDate:[NSDate date]], msg];
            [fh writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
            [fh closeFile];
        }
    }
}

#pragma mark - 工具函数

BOOL isAdViewController(UIViewController *vc) {
    if (!vc) return NO;
    NSString *className = NSStringFromClass([vc class]);
    NSArray *adKeywords = @[
        @"Ad", @"AD", @"Advert", @"Reward", @"Video", @"Interstitial",
        @"Splash", @"Sigmob", @"Pangle", @"CSJ", @"GDT", @"GDTViad",
        @"KSAd", @"BaiduAd", @"BDAd", @"TencentAd", @"Inspire",
        @"FullScreen", @"Express", @"NativeExpress", @"FeedAd",
        @"SplashAd", @"RewardVideo", @"InterstitialAd", @"BUAd",
        @"BUNative", @"BURewarded", @"BUFullscreen", @"GDTAd",
        @"GDTReward", @"SigmobAd", @"WindAd", @"Mintegral", @"MTG"
    ];
    for (NSString *kw in adKeywords) {
        if ([className containsString:kw]) return YES;
    }
    if ([className hasPrefix:@"Ad"] || [className hasSuffix:@"Ad"]) return YES;
    return NO;
}

UIViewController *getTopVC(void) {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window) return nil;
    UIViewController *vc = window.rootViewController;
    while (vc.presentedViewController) vc = vc.presentedViewController;
    if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = [(UINavigationController *)vc visibleViewController];
    }
    return vc;
}

void tryClickSkipButton(void) {
    UIViewController *vc = getTopVC();
    if (!vc) return;
    __block BOOL found = NO;
    void (^findButton)(UIView *) = ^(UIView *view) {
        if (found) return;
        for (UIView *sub in view.subviews) {
            if (found) break;
            if ([sub isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)sub;
                NSString *title = btn.titleLabel.text;
                if (title && ([title containsString:@"跳过"] || [title containsString:@"Skip"] || [title containsString:@"skip"])) {
                    writeLog([NSString stringWithFormat:@"C-找到跳过按钮: %@, 执行点击", title]);
                    [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
                    found = YES;
                    return;
                }
            }
            findButton(sub);
        }
    };
    findButton(vc.view);
    if (!found) writeLog(@"C-未找到跳过按钮");
}

#pragma mark - A方案核心：AVPlayer 加速（JailedSpeedAds 验证有效逻辑）

%hook AVPlayer

- (void)setRate:(float)rate {
    if (g_A_enabled) {
        float accelerated = rate * g_speed_multiplier;
        static int logCount = 0;
        if (logCount < 10) {
            writeLog([NSString stringWithFormat:@"A-AVPlayer setRate: %.2f -> %.2f (加速%.0fx)", rate, accelerated, g_speed_multiplier]);
            logCount++;
        }
        %orig(accelerated);
    } else {
        %orig(rate);
    }
}

- (float)rate {
    float r = %orig();
    if (g_A_enabled) {
        return r * 0.5f;
    }
    return r;
}

%end

#pragma mark - 广告页面检测（日志 + C方案触发）

%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    if (isAdViewController(self)) {
        g_C_triggered = NO;
        writeLog([NSString stringWithFormat:@"检测到广告页面: %@", NSStringFromClass([self class])]);
        __weak UIViewController *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!g_C_triggered && weakSelf && weakSelf.view.window) {
                g_C_triggered = YES;
                writeLog(@"A方案5秒未结束，降级启用C方案");
                tryClickSkipButton();
            }
        });
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    %orig;
    if (isAdViewController(self)) {
        g_C_triggered = NO;
        writeLog(@"广告页面消失");
    }
}

%end

#pragma mark - C方案：UILabel 倒计时修改兜底

%hook UILabel

- (void)setText:(NSString *)text {
    if (g_C_enabled && g_C_triggered && text && text.length > 0) {
        NSError *err = nil;
        NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:@"(\\d+)\\s*s|剩余\\s*(\\d+)\\s*秒|(\\d+)秒|\\d+:\\d+" options:0 error:&err];
        if (!err) {
            NSTextCheckingResult *res = [reg firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
            if (res) {
                writeLog([NSString stringWithFormat:@"C-修改倒计时: '%@' -> '0s'", text]);
                %orig(@"0s");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    tryClickSkipButton();
                });
                return;
            }
        }
    }
    %orig(text);
}

%end

#pragma mark - 构造函数

%ctor {
    @autoreleasepool {
        [[NSFileManager defaultManager] removeItemAtPath:LOG_FILE error:nil];
        writeLog(@"==== AdSkipTweak v3.0 加载完成 ====");
        writeLog([NSString stringWithFormat:@"A方案(AVPlayer加速): 开启, 倍率: %.0fx", g_speed_multiplier]);
        writeLog(@"B方案(磁盘日志): 开启, 路径: /tmp/adskip_log.txt");
        writeLog(@"C方案(UI修改兜底): 开启");
        writeLog(@"核心: Hook AVPlayer setRate 乘以600倍，广告视频瞬间播完");
    }
}
