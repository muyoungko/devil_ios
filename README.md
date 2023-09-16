# 라이브러리 업데이트 2022/6/21
Installing Alamofire 5.6.1 (was 5.4.3)
Installing AppAuth 1.5.0 (was 1.4.0)
Installing FBSDKCoreKit 9.3.0 (was 11.0.1)
Installing FBSDKLoginKit 9.3.0 (was 11.0.1)
Installing FBSDKShareKit 9.3.0 (was 11.0.1)
Installing Firebase 9.1.0 (was 8.3.0)
Installing FirebaseAnalytics 9.1.0 (was 8.3.0)
Installing FirebaseAuth 9.1.0 (was 8.3.0)
Installing FirebaseCore 9.1.0 (was 8.3.0)
Installing FirebaseCoreDiagnostics 9.1.0 (was 8.3.0)
Installing FirebaseCoreInternal (9.1.0)
Installing FirebaseCrashlytics 9.1.0 (was 8.3.0)
Installing FirebaseDynamicLinks 9.1.0 (was 8.3.0)
Installing FirebaseInstallations 9.1.0 (was 8.3.0)
Installing FirebaseMessaging 9.1.0 (was 8.3.0)

# Scence 전환
SceneDelegate 만듬 
AppDelegate에 window 관련 코드 삭제 
Info.plist에 UIApplicationSceneManifest 부분 추가

# Google Ads 탑재
AppDelegate에 DevilSdkGoogleAdsDelegate 프로토콜 구현

@property(nonatomic, strong) GADInterstitialAd *interstitial;
@property (nonatomic, retain) GADRewardedAd* rewardedAd;

[DevilSdk sharedInstance].devilSdkGoogleAdsDelegate = self;
[[DevilSdk sharedInstance] addCustomJevil:[JevilAds class]];
    
-(void)loadAds:(id)params complete:(void (^)(id res))callback
-(void)showAds:(id)params complete:(void (^)(id res))callback


# 이상한 오류
ERROR ITMS-90206: "Invalid Bundle. The bundle at 'devil.app/Frameworks/devilcore.framework' contains disallowed file 'Frameworks'."
devilcore target의 Build Setting 에서 Embed 검색
Always Embed Swift Standard Libraries
YES -> NO 로 변경함
https://stackoverflow.com/questions/25777958/validation-error-invalid-bundle-the-bundle-at-contains-disallowed-file-fr?lq=1

# ios 16 xcode 14 컴파일오류
Pod file 변경 
Podfile platform :ios, '16.0'

pod 재설치
pod deintegrate
pod install

카카오 관련 오류는 다음과 같이 수정
pod 'KakaoSDKCommon', '2.11.3'  # 필수 요소를 담은 공통 모듈
pod 'KakaoSDKAuth', '2.11.3'  # 사용자 인증
pod 'KakaoSDKUser', '2.11.3'  # 카카오 로그인, 사용자 관리
pod 'KakaoSDKTalk', '2.11.3'  # 친구, 메시지(카카오톡)
pod 'KakaoSDKStory', '2.11.3'  # 카카오스토리
참고 https://devtalk.kakao.com/t/swift5-7-xcode14-beta3/124083/12

facebook sdk의 team sigin은 적절히 변경 

# NFC TAG ndef read troubleshooting 
https://stackoverflow.com/questions/56453525/missing-required-entitlement-for-nfctagreadersession
put it in the info plist
<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
<array>
    <string>D2760000850101</string>
</array>
<key>com.apple.developer.nfc.readersession.felica.systemcodes</key>
<array>
    <string>12FC</string>
</array>

# Multiple commands produce Error 해결법
target의 Copy Bundle Resource 에서 문제되는 파일 제거


# Library not loaded 해결
