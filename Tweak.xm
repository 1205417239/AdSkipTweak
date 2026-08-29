#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <substrate.h>
#import <mach/mach_time.h>

#define LOG_FILE @"/tmp/adskip_log.txt"

#pragma mark - 全局状态

static BOOL g_adShowing = NO;        // 是否正在展示广告
static BOOL g_A_enabled = YES;        // A方案：时间加速总开关
static BOOL g_C_enabled = YES;        // C方案：UI修改总开关
static double g_time_speed = 3.0;     // A方案时间加速倍率
static BOOL g_C_triggered = NO;       // C方案是否已触发（降级标志）
static double g_adStartReal = 0;      // 广告开始时的真实时间

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

#pragma mark - A方案：系统时间加速 Hook

// CACurrentMediaTime
static double (*orig_CACurrentMediaTime)(void);
double hook_CACurrentMediaTime(void) {
    double real = orig_CACurrentMediaTime();
    if (g_adShowing && g_A_enabled) {
        // 增量加速：只加速广告展示期间流逝的时间
        static double lastReal = 0;
        static double fakeBase = 0;
        if (lastReal == 0) {
            lastReal = real;
            fakeBase = real;
        }
        double elapsed = real - lastReal;
        double fake = fakeBase + elapsed * g_time_speed;
        lastReal = real;
        fakeBase = fake;
        return fake;
    }
    return real;
}

// mach_absolute_time
static uint64_t (*orig_mach_absolute_time)(void);
uint64_t hook_mach_absolute_time(void) {
    uint64_t real = orig_mach_absolute_time();
    if (g_adShowing && g_A_enabled) {
        static uint64_t lastReal = 0;
        static uint64_t fakeBase = 0;
        if (lastReal == 0) {
            lastReal = real;
            fakeBase = real;
        }
        uint64_t elapsed = real - lastReal;
        uint64_t fake = fakeBase + elapsed * (uint64_t)g_time_speed;
        lastReal = real;
        fakeBase = fake;
        return fake;
    }
    return real;
}

#pragma mark - 工具函数

// 检测是否是广告页面
BOOL isAdViewController(UIViewController *vc) {
    if (!vc) return NO;
    NSString *className = NSStringFromClass([vc class]);
    NSArray *adKeywords = @[
        @"Ad", @"AD", @"Advert", @"Reward", @"Video", @"Interstitial",
        @"Splash", @"Sigmob", @"Pangle", @"CSJ", @"GDT", @"GDTViad",
        @"KSAd", @"BaiduAd", @"BDAd", @"TencentAd", @"Inspire",
        @"FullScreen", @"Express", @"NativeExpress", @"FeedAd",
        @"SplashAd", @"RewardVideo", @"InterstitialAd"
    ];
    for (NSString *kw in adKeywords) {
        if ([className containsString:kw]) return YES;
    }
    if ([className hasPrefix:@"Ad"] || [className hasSuffix:@"Ad"]) return YES;
    return NO;
}

// 获取顶层 ViewController
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

// C方案：递归查找并点击跳过按钮
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
                if (title && ([title containsString:@"跳过"] || [title containsString:@"Skip"] || [title containsString:@"skip"] || [title containsString:@"跳过广告"])) {
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
    if (!found) {
        writeLog(@"C-未找到跳过按钮");
    }
}

#pragma mark - 广告页面检测 Hook

%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;

    if (isAdViewController(self)) {
        g_adShowing = YES;
        g_C_triggered = NO;
        g_adStartReal = orig_CACurrentMediaTime ? orig_CACurrentMediaTime() : CACurrentMediaTime();

        NSString *className = NSStringFromClass([self class]);
        writeLog([NSString stringWithFormat:@"检测到广告页面: %@", className]);
        writeLog([NSString stringWithFormat:@"A方案启动: 时间加速 %.1fx", g_time_speed]);

        // 降级检查：3秒后如果广告还在，说明A没生效，启用C
        __weak UIViewController *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (g_adShowing && !g_C_triggered && weakSelf && weakSelf.view.window) {
                g_C_triggered = YES;
                writeLog(@"A方案3秒未结束，降级启用C方案(UI修改倒计时+点击跳过)");
                tryClickSkipButton();
            }
        });
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    %orig;

    if (isAdViewController(self)) {
        g_adShowing = NO;
        g_C_triggered = NO;
        double duration = (orig_CACurrentMediaTime ? orig_CACurrentMediaTime() : CACurrentMediaTime()) - g_adStartReal;
        writeLog([NSString stringWithFormat:@"广告页面消失，实际展示时长: %.2fs, 关闭加速", duration]);
    }
}

%end

#pragma mark - C方案：UILabel 倒计时修改 Hook

%hook UILabel

- (void)setText:(NSString *)text {
    // C方案：广告展示中且已降级时，修改倒计时文本
    if (g_adShowing && g_C_enabled && g_C_triggered && text && text.length > 0) {
        NSError *err = nil;
        NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:@"(\\d+)\\s*s|剩余\\s*(\\d+)\\s*秒|(\\d+)秒|\\d+:\\d+" options:0 error:&err];
        if (!err) {
            NSTextCheckingResult *res = [reg firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
            if (res) {
                writeLog([NSString stringWithFormat:@"C-修改倒计时标签: '%@' -> '0s'", text]);
                %orig(@"0s");
                // 修改后再次尝试点击跳过
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
        // 清空旧日志
        [[NSFileManager defaultManager] removeItemAtPath:LOG_FILE error:nil];

        writeLog(@"==== AdSkipTweak v2.0 加载完成 ====");
        writeLog([NSString stringWithFormat:@"A方案(时间加速): %@, 倍率: %.1fx", g_A_enabled ? @"开启" : @"关闭", g_time_speed]);
        writeLog([NSString stringWithFormat:@"B方案(磁盘日志): 开启, 路径: %@", LOG_FILE]);
        writeLog([NSString stringWithFormat:@"C方案(UI修改): %@", g_C_enabled ? @"开启" : @"关闭"]);
        writeLog(@"降级逻辑: A优先 -> 3秒未生效自动降级C");

        // A方案：安装 C 函数 Hook
        MSHookFunction((void *)&CACurrentMediaTime, (void *)hook_CACurrentMediaTime, (void **)&orig_CACurrentMediaTime);
        MSHookFunction((void *)&mach_absolute_time, (void *)hook_mach_absolute_time, (void **)&orig_mach_absolute_time);

        writeLog(@"所有Hook安装完成");
    }
}
