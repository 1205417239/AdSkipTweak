#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AdSkipManager : NSObject

@property (nonatomic, assign) BOOL enabled;              // 总开关
@property (nonatomic, assign) NSTimeInterval graceTime;  // 宽限时间（广告展示后多久开始跳过，防检测）
@property (nonatomic, assign) NSTimeInterval minShowTime; // 最小展示时间（广告至少展示多久）
@property (nonatomic, assign) BOOL showHUD;               // 是否显示跳过进度框
@property (nonatomic, assign) BOOL skipRewardVideo;       // 是否跳过激励视频
@property (nonatomic, assign) BOOL skipInterstitial;      // 是否跳过插屏广告
@property (nonatomic, assign) BOOL skipSplash;            // 是否跳过开屏广告

+ (instancetype)sharedManager;

// 核心：延迟后对目标对象执行指定方法（伪造广告完成回调）
- (void)triggerCallbackOnTarget:(id)target
                        selector:(SEL)selector
                            args:(NSArray *)args
                      afterDelay:(NSTimeInterval)delay;

// 显示/隐藏跳过进度框
- (void)showSkipHUDWithText:(NSString *)text;
- (void)hideSkipHUD;

// 检测当前顶部页面是否是广告
- (BOOL)isAdViewController:(UIViewController *)vc;

// 自动关闭当前广告页面
- (void)dismissCurrentAd;

// 加载配置
- (void)loadConfig;

@end
