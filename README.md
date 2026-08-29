# AdSkipTweak

iOS 广告自动跳过 Tweak，基于广告回调伪造原理实现。

## 原理

不修改系统时间，不加速倒计时。核心是**手动触发广告 SDK 的"广告已看完"回调**，让广告 SDK 误以为用户已经看完了广告，从而直接发放奖励。

工作流程：
1. 检测到广告页面展示（通过类名识别）
2. 显示"广告跳过中..."进度框
3. 等待 `graceTime`（宽限时间，防检测）
4. 手动调用广告关闭/完成回调（伪造 watchedTime=duration）
5. 广告 SDK 以为广告已看完，触发奖励发放
6. 等待 `minShowTime`（最小展示时间）
7. 关闭广告页面，隐藏进度框

## 功能

- [x] 激励视频广告自动跳过
- [x] 插屏广告自动跳过
- [x] 开屏广告自动跳过
- [x] 可配置宽限时间（防检测）
- [x] 可配置最小展示时间
- [x] 跳过进度框显示
- [x] 支持常见广告 SDK（穿山甲/优量汇/快手/Sigmob 等）
- [x] 基于 adsspeed 插件分析的回调方法名模式

## 配置

配置文件路径：`/var/mobile/Library/Preferences/com.adskip.tweak.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>enabled</key>
    <true/>
    <key>graceTime</key>
    <real>2.0</real>
    <key>minShowTime</key>
    <real>3.0</real>
    <key>showHUD</key>
    <true/>
    <key>skipRewardVideo</key>
    <true/>
    <key>skipInterstitial</key>
    <true/>
    <key>skipSplash</key>
    <true/>
</dict>
</plist>
```

## 安装

### 越狱设备
1. 下载 `.deb` 包
2. 通过 Filza 或 Cydia 安装
3. 重启 SpringBoard 或使用 `killall -9 SpringBoard`

### TrollStore
1. 下载 `.dylib` 文件
2. 使用 TrollStore 注入到目标应用

## 编译

```bash
# 安装 Theos
git clone --recursive https://github.com/theos/theos.git
export THEOS=$(pwd)/theos

# 编译
make clean package FINALPACKAGE=1
```

## 技术栈

- Theos / Logos（MobileSubstrate）
- Objective-C
- MSHookMessageEx（方法 hook）
- NSInvocation（动态方法调用，伪造回调参数）

## 免责声明

本项目仅供学习研究使用，请勿用于商业用途。使用本软件可能违反应用服务条款，请自行承担风险。
