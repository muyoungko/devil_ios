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


# @rpath Library not loaded WebRTC.framework 해결법

Pods에 있는 WebRTC.framwork를 devil / framework에 추가함
그후 embeded and sign 옵션 켜기

template1 프로젝트에서도 똑같이 한다

# WebRtc에서 "Unsupported architectures. Your executable contains unsupported architectures '[x86_64, i386]'" 해결법

Pods/GoogleWebRTC/Frameworks/frameworks/WebRTC.framework
lipo -remove i386 WebRTC -o WebRTC
lipo -remove x86_64 WebRTC -o WebRTC

에서 위 커맨드로 불필요한 아키텍처를 제거한다

template1 프로젝트에서도 똑같이 한다


#Google map bundle 못찾는 문제(webrtc와 충돌)

google map 7.3.0에서 sub project devil에서
instance 프로젝트에서 webrtc를 포함시
template1 > webrtc > devilcore > googlemap 과
template1 > devilcore > googlemap 이렇게 중복되서 
 
bundle을 못찾고 tile만들때 크래시남
webrtc를 프로젝트 단위로 import하지말고 그냥 코드를 import해서
template1 > webrtc > devilcore(삭제) > googlemap
template1 > devilcore > googlemap 
이상태로 만들어야함


#Google map bundle 못찾는 문제(0.8)
google map 8.x.0 사용시 devilcore에서 GoogleMap.bundle을 못찾음

self.mapView = [[GMSMapView alloc] initWithFrame: CGRectZero camera:camera];
위 코드에서 오류남

그러므로 google map 8.x 를 사용할 수 없음  
target 'devilcore' do
  pod 'GoogleMaps', '8.4.0'
end

# Firebase 최신버전 문제 해결
푸시가 안옴
푸시키가 할당못됨
Firebase Invlid Api 키에 제한이 걸려있음
https://stackoverflow.com/questions/58495985/firebase-403-permission-denied-firebaseerror-installations-requests-are-blo
