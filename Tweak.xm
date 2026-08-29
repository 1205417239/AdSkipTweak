#include <iostream>
#include <string>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import <substrate.h>

//No func
static BOOL returnNo(id self, SEL _cmd) {
    return NO;
}

// 辅助：获取keyWindow
UIWindow *getKeyWindow() {
    for (UIWindow *w in [UIApplication sharedApplication].windows) {
        if (w.isKeyWindow) return w;
    }
    return [UIApplication sharedApplication].windows.firstObject;
}

// H5广告加速JS代码
static NSString *kAdSpeedJS = @"\
(function(){\
  function speed(){\
    try{\
      document.querySelectorAll('video').forEach(function(v){\
        try{ v.playbackRate=16; v.muted=true; v.play(); }catch(e){}\
      });\
      var all=document.querySelectorAll('*');\
      for(var i=0;i<all.length;i++){\
        var el=all[i];\
        if(el.childNodes&&el.childNodes.length===1&&el.childNodes[0].nodeType===3){\
          var t=el.textContent;\
          if(t&&/\\d+\\s*秒/.test(t)){el.textContent=t.replace(/\\d+\\s*秒/,'0秒');}\
          if(t&&/\\d+:\\d+/.test(t)){el.textContent='00:00';}\
          if(t&&/\\d+\\s*s/i.test(t)){el.textContent=t.replace(/\\d+\\s*s/i,'0s');}\
        }\
      }\
    }catch(e){}\
  }\
  speed();\
  try{\
    new MutationObserver(speed).observe(document.body||document.documentElement,{childList:true,subtree:true,characterData:true});\
  }catch(e){}\
  setInterval(speed,500);\
})();";

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
    MSHookMessageEx(objc_getClass("NSNetService"), @selector(addresses), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSNetService"), @selector(initWithCFNetService:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSNetServiceBrowser"), @selector(stop), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSURLConnectionInternalConnection"), @selector(cancelAuthenticationChallenge:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSURLConnectionInternalConnection"), @selector(_timingData), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSURLSessionTaskHTTPAuthenticator"), @selector(sessionTaskHTTPAuthenticatorWithContext:statusCodes:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSURLSessionTaskHTTPAuthenticator"), @selector(setStatusCodes:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSURLSessionTaskLocalHTTPAuthenticator"), @selector(externalAuthenticator), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("__NSCFURLSessionTaskGroup"), @selector(dataTaskWithRequest:completionHandler:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("__NSCFURLSessionTaskGroup"), @selector(forwardingTargetForSelector:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("__NSCFURLSessionTaskGroup"), @selector(dataTaskWithRequest:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("__NSCFURLSessionTaskGroup"), @selector(uploadTaskWithStreamedRequest:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("__NSCFURLSessionTaskGroup"), @selector(_groupConfiguration), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("__NSCFURLSessionTaskGroup"), @selector(_groupSession), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSURLConnectionInternal"), @selector(useCredential:forAuthenticationChallenge:), (IMP)returnNo, NULL);
    MSHookMessageEx(objc_getClass("NSURLConnectionInternal"), @selector(_timingData), (IMP)returnNo, NULL);
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

// ===== 方案A：原生视频广告 - AVPlayer 16倍速 =====
%hook AVPlayer

- (void)setRate:(float)rate {
    // 广告播放时强制16倍速
    if (rate > 0.0f && rate <= 1.0f) {
        %orig(16.0f);
    } else {
        %orig(rate);
    }
}

- (void)play {
    %orig;
    // 延迟设置rate，确保播放器已准备好
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        float curRate = [self rate];
        if (curRate > 0.0f && curRate <= 1.0f) {
            [self setRate:16.0f];
        }
    });
}

%end

// ===== 核心：H5广告加速 - Hook WKWebView 注入JS =====
%hook WKWebView

- (void)loadRequest:(NSURLRequest *)request {
    %orig;
    [self performSelector:@selector(injectAdSpeedJS) withObject:nil afterDelay:1.0];
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    %orig;
    [self performSelector:@selector(injectAdSpeedJS) withObject:nil afterDelay:1.0];
}

- (void)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL {
    %orig;
    [self performSelector:@selector(injectAdSpeedJS) withObject:nil afterDelay:1.0];
}

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType characterEncodingName:(NSString *)characterEncodingName baseURL:(NSURL *)baseURL {
    %orig;
    [self performSelector:@selector(injectAdSpeedJS) withObject:nil afterDelay:1.0];
}

%new
- (void)injectAdSpeedJS {
    if ([self respondsToSelector:@selector(evaluateJavaScript:completionHandler:)]) {
        [self evaluateJavaScript:kAdSpeedJS completionHandler:^(id result, NSError *error) {
            if (error) {
                NSLog(@"[AdSkip] JS注入失败: %@", error.localizedDescription);
            } else {
                NSLog(@"[AdSkip] H5广告加速JS注入成功");
            }
        }];
    }
}

%end

// ===== 画中画拦截 =====
%hook AVPictureInPictureController

- (BOOL)isPictureInPicturePossible {
    return NO;
}

- (void)startPictureInPicture {
    // 不执行
}

- (BOOL)isPictureInPictureActive {
    return NO;
}

%end
