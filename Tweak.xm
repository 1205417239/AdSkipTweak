#include <iostream>
#include <string>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <substrate.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

//No func
static BOOL returnNo(id self, SEL _cmd) {
    return NO;
}

// 辅助：获取keyWindow（兼容iOS13+）
UIWindow *getKeyWindow() {
    for (UIWindow *w in [UIApplication sharedApplication].windows) {
        if (w.isKeyWindow) return w;
    }
    return [UIApplication sharedApplication].windows.firstObject;
}

//Find almost function that contains ads in almost games apps
void hookMethods() {
    MSHookMessageEx(objc_getClass("GADAdSource"), @selector(invalidated), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ALMediationServiceAdDelegateProxy"), @selector(didLoadAd:withExtraInfo:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("AdsHandler"), @selector(pauseAll:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("AdsHandler"), @selector(clear), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("AdsHandler"), @selector(setPossibleAdsPerHour:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("AdsHandler"), @selector(init), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("AdsHandler"), @selector(clearTimeSinceLiveStarted), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("AdsHandler"), @selector(updateTimeSinceLiveStarted), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("BasePlayerView"), @selector(OnPlayer_AdStarted:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("FullScreenViewTVAIS"), @selector(getLastPlayedChannel), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("FullScreenViewTVAIS"), @selector(startPlayChannel:forceStart:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RFQVideoPlayer"), @selector(checkIsPreviewEnded), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RFQVideoPlayerAd"), @selector(onAdStartedPlay), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RFQVideoPlayerAd"), @selector(adShouldStartPlay), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RFQVideoPlayerAd"), @selector(setAdShouldStartPlay:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RSVodHead"), @selector(isPreview), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RSVodHead"), @selector(isPreviewEnded), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RSVodHead"), @selector(setIsPreview:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RSVodHead"), @selector(setIsPreviewEnded:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("TAGPreviewManager"), @selector(isPreviewingContainer:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("TabBarBaseVC"), @selector(OnHeadLoadSuccess), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("UMPConsentInformation"), @selector(canRequestAds), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("XmppVCardInfo"), @selector(hasAnyAds), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("XmppVCardInfo"), @selector(hasNativeAds), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("XmppVCardInfo"), @selector(hasRegularAds), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("SCSnapAdsAdResponsePersistentCache"), @selector(_getAdResponse:removeAdResponseOnHit:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("SCSnapAdsAdSourceConfig"), @selector(shouldDisableServeRequest), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("SCSnapAdsAdSourceConfig"), @selector(protoServeEndpoint), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("SCSnapAdsAdSourceConfig"), @selector(protoInitEndpoint), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("SCSnapAdsDynamicAdMediaManagerImpl"), @selector(removeMediaDataSource:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("SCSnapAdsOnDeviceInfoRecordCoordinator"), @selector(_handleRemoveOnDeviceInfoRecordsWithSuccess:completionBlock:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("SCSnapAdsOnDeviceInfoRecordCoordinator"), @selector(removeAllOnDeviceInfoRecordsForSaid:completionQueue:completionBlock:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("SCSnapAdsServeResponseDataStore"), @selector(_removeAdResponseForIdentifier:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("SCSnapAdsServeResponseDataStore"), @selector(removeAdResponseForIdentifier:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSNetService"), @selector(publish), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSNetService"), @selector(stop), (IMP)returnNo, NULL);
    //MSHookMessageEx(objc_getClass("NSNetService"), @selector(dealloc), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSNetService"), @selector(addresses), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSNetService"), @selector(initWithCFNetService:), (IMP)returnNo, NULL);
    //MSHookMessageEx(objc_getClass("NSNetServiceBrowser"), @selector(dealloc), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSNetServiceBrowser"), @selector(stop), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSURLConnectionInternalConnection"), @selector(cancelAuthenticationChallenge:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSURLConnectionInternalConnection"), @selector(_timingData), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSURLSessionTaskHTTPAuthenticator"), @selector(sessionTaskHTTPAuthenticatorWithContext:statusCodes:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSURLSessionTaskHTTPAuthenticator"), @selector(setStatusCodes:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSURLSessionTaskLocalHTTPAuthenticator"), @selector(externalAuthenticator), (IMP)returnNo, NULL);
    //MSHookMessageEx(objc_getClass("NWStreamPair"), @selector(dealloc), (IMP)returnNo, NULL);
    //MSHookMessageEx(objc_getClass("__NSCFURLLocalStreamTaskFromDataTaskDataBlobby"), @selector(dealloc), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("__NSCFURLSessionTaskGroup"), @selector(dataTaskWithRequest:completionHandler:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("__NSCFURLSessionTaskGroup"), @selector(forwardingTargetForSelector:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("__NSCFURLSessionTaskGroup"), @selector(dataTaskWithRequest:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("__NSCFURLSessionTaskGroup"), @selector(uploadTaskWithStreamedRequest:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("__NSCFURLSessionTaskGroup"), @selector(_groupConfiguration), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("__NSCFURLSessionTaskGroup"), @selector(_groupSession), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSURLConnectionInternal"), @selector(useCredential:forAuthenticationChallenge:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSURLConnectionInternal"), @selector(_timingData), (IMP)returnNo, NULL);
    //MSHookMessageEx(objc_getClass("NSURLSessionTaskBackgroundHTTPAuthenticator"), @selector(dealloc), (IMP)returnNo, NULL);
    //MSHookMessageEx(objc_getClass("NSURLSessionTaskDependency"), @selector(dealloc), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("__NSCFURLSessionXPC"), @selector(initialize), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("FPUserCredentials"), @selector(adremoval_enabled), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ALIncentivizedInterstitialAd"), @selector(isReadyForDisplay), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ALMediatedAd"), @selector(isReady), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ALStoreKitProductViewController"), @selector(isReady), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ALStoreProductViewControllerWrapper"), @selector(isReady), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("FBAdDSLBridgeViewController"), @selector(isReadyToPresent), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("IMAAd"), @selector(isSkippable), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("IMAAd"), @selector(isUiDisabled), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ISAdMobBannerAdapter"), @selector(isLargeScreen), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ISBaseAdUnitInteractionSmash"), @selector(isReadyToShow), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ISBaseAdUnitManager"), @selector(isReadyToShow), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ISBaseAdUnitSmash"), @selector(isReadyToShow), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ISDemandOnlyIsSmash"), @selector(isReadyToShow), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ISDemandOnlyRvSmash"), @selector(isReadyToShow), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ISLWSProgRvSmash"), @selector(isReadyToShow), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ISProgIsSmash"), @selector(isReadyToShow), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("MAAd"), @selector(isReady), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("MAAppOpenAd"), @selector(isReady), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("MAFullscreenAdController"), @selector(isReady), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("MAInterstitialAd"), @selector(isReady), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("MARewardedAd"), @selector(isReady), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("MARewardedInterstitialAd"), @selector(isReady), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADView"), @selector(initWithFrame:context:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ALDCreativeDebuggerTableViewDataSource"), @selector(initializeWithDisplayedAds:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ALMediationAdLoadCoordinator"), @selector(didLoadAd:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ALMediationSetting"), @selector(fullscreenAdShouldReturnReadyWhenAdLoadIsInProgress), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADBannerAd"), @selector(adView), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADBannerAd"), @selector(videoController), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADCustomEventBannerAdRenderer"), @selector(renderWithServerTransaction:adConfiguration:completionHandler:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADFullScreenAdViewController"), @selector(viewWillAppear:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADFullScreenAdViewController"), @selector(presented), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADFullScreenAdViewController"), @selector(canPresentFromViewController:error:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADInlineInterstitialAdRenderer"), @selector(renderWithServerTransaction:adConfiguration:completionHandler:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADInlineMultipleNativeAdsRenderer"), @selector(renderWithServerTransaction:adConfiguration:completionHandler:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADInlineMultipleNativeAdsRenderer"), @selector(init), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADMediationBannerAdRenderer"), @selector(renderWithServerTransaction:adConfiguration:completionHandler:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADMediationBannerAdRenderer"), @selector(adapter:didReceiveAdView:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADRTBMediationBannerAdRenderer"), @selector(renderWithServerTransaction:adConfiguration:completionHandler:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADUnifiedMediationBannerAdRenderer"), @selector(renderWithServerTransaction:adConfiguration:completionHandler:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("MANativeAdSource"), @selector(isAdLoading), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADInlineBannerAdRenderer"), @selector(renderWithServerTransaction:adConfiguration:completionHandler:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RNGoogleMobileAdsBannerComponent"), @selector(didSetProps:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RNGoogleMobileAdsBannerComponent"), @selector(banner), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RNGoogleMobileAdsBannerComponent"), @selector(requested), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RNGoogleMobileAdsBannerComponent"), @selector(setBanner:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RNGoogleMobileAdsBannerComponent"), @selector(request), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RNGoogleMobileAdsBannerComponent"), @selector(propsChanged), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RNGoogleMobileAdsBannerComponent"), @selector(onNativeEvent), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RNGoogleMobileAdsBannerComponent"), @selector(setPropsChanged:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RNGoogleMobileAdsBannerViewManager"), @selector(view), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RNGoogleMobileAdsBannerViewManager"), @selector(methodQueue), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RNGoogleMobileAdsBannerViewManager"), @selector(propConfig_unitId), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RNGoogleMobileAdsBannerViewManager"), @selector(propConfig_sizes), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RNGoogleMobileAdsBannerViewManager"), @selector(propConfig_onNativeEvent), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RNGoogleMobileAdsBannerViewManager"), @selector(propConfig_manualImpressionsEnabled), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RNGoogleMobileAdsBannerViewManager"), @selector(recordManualImpression:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RNGoogleMobileAdsBannerViewManager"), @selector(bridge), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("RNGoogleMobileAdsBannerViewManager"), @selector(propConfig_request), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("VungleURLConfiguration"), @selector(setAdsURL:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADAdRenderResult"), @selector(rendererClassString), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADAdRenderResult"), @selector(setRendererClassString:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADInlineSingleNativeAdRenderer"), @selector(init), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADInternalBannerView"), @selector(callBackAdViewDidReceiveAd), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADMediatedAdRenderer"), @selector(adapter:didReceiveAdView:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADBannerView"), @selector(bannerViewDidReceiveAd:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADBannerView"), @selector(bannerView:didFailToReceiveAdWithError:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADBannerView"), @selector(bannerViewDidRecordImpression:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADBannerView"), @selector(bannerViewWillPresentScreen:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADBannerView"), @selector(adViewIntrinsicContentSizeDidChange:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADBannerView"), @selector(setAutoloadEnabled:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADBannerView"), @selector(setAdUnitID:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADBannerView"), @selector(loadRequest:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("_TtC9BusTaiwan20YBGoogleBannerAdView"), @selector(loadAd), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ALAdLoadState"), @selector(isWaitingForAd), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ALAdLoadState"), @selector(setIsWaitingForAd:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ALAdService"), @selector(hasPreloadedAdOfSize:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ALAdService"), @selector(hasPreloadedAdForZoneIdentifier:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ALFullScreenAdTracker"), @selector(isFullScreenAdShowing), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ALMediationAdLoadState"), @selector(isWaitingForAd), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ALMediationAdLoadState"), @selector(setIsWaitingForAd:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ALMediationAdapterRouter"), @selector(isAdShowingForAdapter:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("ALNativeAdService"), @selector(loadNextAdAndNotify:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("APMPersistedConfig"), @selector(allowPersonalizedAds), (IMP)returnNo, NULL);
    
    MSHookMessageEx(objc_getClass("NSNetService"), sel_getUid("dealloc"), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSNetServiceBrowser"), sel_getUid("dealloc"), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NWStreamPair"), sel_getUid("dealloc"), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("__NSCFURLLocalStreamTaskFromDataTaskDataBlobby"), sel_getUid("dealloc"), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSURLSessionTaskBackgroundHTTPAuthenticator"), sel_getUid("dealloc"), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSURLSessionTaskDependency"), sel_getUid("dealloc"), (IMP)returnNo, NULL);

    //also return no for jb detect
    MSHookMessageEx(objc_getClass("BUDeviceHelper"), @selector(bu_isJailBroken), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("EBAppLogDeviceHelper"), @selector(isJailBroken), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADMinimumVersionSupport"), @selector(OSIsSupported), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADOMIDAdSessionRegistry"), @selector(isActive), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADOMIDAdSessionRegistry"), @selector(removeAdSession:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADOMIDAdSessionRegistry"), @selector(adSessions), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADOMIDAdSessionRegistry"), @selector(activeAdSessions), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("GADOMIDAdSessionRegistry"), @selector(addAdSession:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("HMDBUInfo"), @selector(isJailBroken), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("MobClick"), @selector(isJailbroken), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("MobClick"), @selector(isPirated), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("SSEDeviceStatus"), @selector(jailBroken), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("UMUtils"), @selector(isDeviceJailBreak), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("UMUtils"), @selector(isAppPirate), (IMP)returnNo, NULL);
}

// Initialize the tweak
__attribute__((constructor))
static void initialize() {
    hookMethods();
}

//skip ads if it was a video player
%hook AVPlayer

- (void)setRate:(float)rate {
 %orig(rate * 600.0f);
}

- (float)rate{
 float r = %orig;
 return r * 0.5f;
}

%end
// ===== 增强：倒计时Label直接修改 =====
%hook UILabel

- (void)setText:(NSString *)text {
    if (text && text.length > 0) {
        // 匹配各种倒计时模式: "30秒后发放" "剩余30秒" "30s" "00:30" "30秒"
        NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:@"(\\d+)\\s*秒.*发放|剩余\\s*(\\d+)\\s*秒|(\\d+)\\s*秒|(\\d+)\\s*s|\\d+:\\d+" options:0 error:nil];
        NSTextCheckingResult *res = [reg firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
        if (res) {
            // 直接改成0，让倒计时瞬间结束
            %orig(@"0秒后发放");
            // 延迟尝试点击关闭/跳过按钮
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIWindow *win = getKeyWindow();
                UIViewController *vc = win.rootViewController;
                while (vc.presentedViewController) vc = vc.presentedViewController;
                // 递归查找按钮
                __block void (^findBtn)(UIView *);
                findBtn = ^(UIView *view) {
                    for (UIView *sub in view.subviews) {
                        if ([sub isKindOfClass:[UIButton class]]) {
                            UIButton *btn = (UIButton *)sub;
                            NSString *t = btn.titleLabel.text;
                            if (t && ([t containsString:@"跳过"] || [t containsString:@"关闭"] || [t containsString:@"Skip"])) {
                                [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
                                return;
                            }
                        }
                        findBtn(sub);
                    }
                };
                findBtn(vc.view);
            });
            return;
        }
    }
    %orig(text);
}

%end

// ===== 增强：画中画拦截 =====
%hook AVPictureInPictureController

- (BOOL)isPictureInPicturePossible {
    return NO;
}

- (void)startPictureInPicture {
    // 不执行，阻止进入画中画
}

- (BOOL)isPictureInPictureActive {
    return NO;
}

%end

// ===== 增强：弹窗保活倒计时（弹窗不关，持续修改第一层倒计时Label） =====
%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    // 延迟检测弹窗（不限字体大小，只要是弹窗）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = getKeyWindow();
        if (!win) return;

        // 检测弹窗：方式1 - 有presentedViewController；方式2 - 包含"更快拿奖"等关键词的Label
        __block BOOL hasPopup = NO;
        UIViewController *top = win.rootViewController;
        while (top.presentedViewController) {
            top = top.presentedViewController;
            hasPopup = YES;
        }

        __block void (^scanPopup)(UIView *);
        scanPopup = ^(UIView *view) {
            if (hasPopup) return;
            for (UIView *sub in view.subviews) {
                if (hasPopup) break;
                if ([sub isKindOfClass:[UILabel class]]) {
                    UILabel *lab = (UILabel *)sub;
                    if (lab.text && ([lab.text containsString:@"更快拿奖"] || [lab.text containsString:@"浏览广告"] || [lab.text containsString:@"秒更快"])) {
                        hasPopup = YES;
                        return;
                    }
                }
                scanPopup(sub);
            }
        };
        scanPopup(win);

        if (hasPopup) {
            // 弹窗存在，启动定时器保活倒计时（持续主动修改第一层倒计时Label为0）
            __block int tickCount = 0;
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer *t) {
                tickCount++;
                if (tickCount > 120) { // 最多保活36秒
                    [t invalidate];
                    return;
                }

                UIWindow *w = getKeyWindow();
                if (!w) return;

                // 遍历查找倒计时Label，直接改成0（不限字体大小）
                __block void (^findCountdown)(UIView *);
                findCountdown = ^(UIView *view) {
                    for (UIView *sub in view.subviews) {
                        if ([sub isKindOfClass:[UILabel class]]) {
                            UILabel *lab = (UILabel *)sub;
                            if (lab.text && lab.text.length > 0) {
                                NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:@"(\\d+)\\s*秒.*发放|剩余\\s*(\\d+)\\s*秒|(\\d+)\\s*秒|(\\d+)\\s*s|\\d+:\\d+" options:0 error:nil];
                                NSTextCheckingResult *res = [reg firstMatchInString:lab.text options:0 range:NSMakeRange(0, lab.text.length)];
                                if (res) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        lab.text = @"0秒后发放";
                                    });
                                }
                            }
                        }
                        findCountdown(sub);
                    }
                };
                findCountdown(w);

                // 同时尝试点击关闭/跳过按钮（不关弹窗，只点跳过）
                __block void (^findBtn)(UIView *);
                findBtn = ^(UIView *view) {
                    for (UIView *sub in view.subviews) {
                        if ([sub isKindOfClass:[UIButton class]]) {
                            UIButton *btn = (UIButton *)sub;
                            NSString *t = btn.titleLabel.text;
                            if (t && ([t containsString:@"跳过"] || [t containsString:@"Skip"])) {
                                [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
                                return;
                            }
                        }
                        findBtn(sub);
                    }
                };
                findBtn(w);
            }];
            [timer fire];
        }
    });
}

%end
