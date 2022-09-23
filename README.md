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



