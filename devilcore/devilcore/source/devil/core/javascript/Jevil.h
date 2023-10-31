//
//  Jevil.h
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/15.
//

@import JavaScriptCore;

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol Jevil <JSExport>

+ (instancetype)contactWithName:(NSString *)name
                          phone:(NSString *)phone
                        address:(NSString *)address;

+ (BOOL)isLogin;
+ (void)go:(NSString*)screenName :(id)param;
+ (void)replaceScreen:(NSString*)screenName :(id)param;
+ (void)rootScreen:(NSString*)screenName :(id)param;
+ (void)markScreen;
+ (void)backToMarkScreen;
+ (void)tab:(NSString*)screenName;
+ (void)finish:(id)callbackData;
+ (void)finishThen:(JSValue *)callback;
+ (void)back;
+ (void)toast:(NSString*)msg;
+ (void)alert:(NSString*)msg;
+ (void)alertFinish:(NSString*)msg;
+ (void)alertThen:(NSString*)msg :(JSValue *)callback;
+ (void)alertThenOption:(id)param :(JSValue *)callback;
+ (void)confirm:(NSString*)msg :(NSString*)yes :(NSString*)no :(JSValue *)callback;
+ (void)startLoading;
+ (void)stopLoading;
+ (void)save:(NSString *)key :(NSString *)value;
+ (void)remove:(NSString *)key;
+ (NSString*)get:(NSString *)key;
+ (void)httpWithMultipartPost:(NSString *)url :(NSDictionary*)headerObject :(NSDictionary*)param :(JSValue *)callback;
+ (void)httpWithFilePath:(NSString *)method :(NSString *)url :(NSDictionary*)headerObject :(NSString*)filepath :(JSValue *)callback;
+ (void)http:(NSString *)method :(NSString *)url :(NSDictionary*)headerObject :(NSDictionary*)body :(JSValue *)callback;
+ (void)get:(NSString *)url then:(JSValue *)callback;
+ (void)getMany:(NSArray *)url then:(JSValue *)callback;
+ (void)post:(NSString *)url :(id)param then:(JSValue *)callback;
+ (void)put:(NSString *)url :(id)param then:(JSValue *)callback;
+ (void)uploadS3:(NSArray*)file :(JSValue *)callback;
+ (void)uploadS3Secure:(NSArray*)paths :(JSValue *)callback;
+ (void)uploadS3Core:(NSArray*)paths :(NSString*)put_url :(JSValue *)callback;
+ (void)sendPushKeyWithDevilServer;
+ (void)getThenWithHeader:(NSString *)url :(id)header :(JSValue *)callback;
+ (void)postThenWithHeader:(NSString *)url :(id)header :(id)param :(JSValue *)callback;
+ (void)update;
+ (void)updateThis;
+ (void)focus:(NSString*)nodeName;
+ (void)hideKeyboard;
+ (void)scrollTo:(NSString*)nodeName :(int)index :(id)param;
+ (void)scrollUp:(NSString*)nodeName;
+ (void)popup:(NSString*)blockName :(NSDictionary*)param :(JSValue *)callback;
+ (void)popupClose:(id)yes;
+ (void)popupAddress:(NSDictionary*)param :(JSValue *)callback;
+ (void)popupSelect:(NSArray *)arrayString :(NSDictionary*)param :(JSValue *)callback;
+ (void)popupDate:(NSDictionary*)param :(JSValue *)callback;
+ (void)popupTime:(NSDictionary*)param :(JSValue *)callback;
+ (void)resetTimer:(NSString *)nodeName;
+ (void)setViewPagerSelectedIndex:(NSString *)nodeName :(int)index;
+ (int)getViewPagerSelectedIndex:(NSString *)nodeName;
+ (void)viewPagerSelectedCallback:(NSString*)nodeName :(JSValue*)callback;
+ (void)isWifi:(JSValue *)callback;
+ (void)wifiList:(JSValue *)callback;
+ (void)wifiConnect:(NSString*)ssid :(NSString*)password :(JSValue *)callback;
+ (void)gallery:(NSDictionary*)param :(JSValue *)callback;
+ (void)galleryList:(NSDictionary*)param :(JSValue *)callback;
+ (void)gallerySystem:(NSDictionary*)param :(JSValue *)callback;
+ (void)cameraSystem:(NSDictionary*)param :(JSValue *)callback;
+ (void)camera:(NSDictionary*)param :(JSValue *)callback;
+ (void)cameraQr:(NSDictionary*)param :(JSValue *)callback;
+ (void)cameraQrClose;
+ (void)share:(NSString*)url;
+ (void)out:(NSString*)url :(BOOL)force;
+ (void)saveFileFromUrl:(NSDictionary*)param :(JSValue *)callback;
+ (void)downloadAndView:(NSString*)url;
+ (void)downloadAndShare:(NSString*)url;
+ (void)download:(NSString*)url;
+ (void)sound:(NSDictionary*)param;
+ (id)soundCurrentInfo;
+ (void)soundCallback:(JSValue*)callback;
+ (void)soundControlCallback:(JSValue *)callback;
+ (void)soundTick:(JSValue*)callback;
+ (void)soundPause;
+ (void)soundStop;
+ (void)soundResume;
+ (BOOL)soundIsPlaying;
+ (void)soundMove:(int)sec;
+ (void)soundSeek:(int)sec;
+ (void)soundSpeed:(NSString*)speed;
+ (void)speechRecognizer:(NSDictionary*)param :(JSValue*)callback;
+ (void)stopSpeechRecognizer;
+ (NSString*)recordStatus;
+ (void)recordStart:(NSDictionary*)param :(JSValue*)callback;
+ (void)recordTick:(JSValue*)callback;
+ (void)recordStop:(JSValue*)callback;
+ (void)recordCancelCallback:(JSValue*)callback;

+ (void)getLocation:(NSDictionary*)param :(JSValue*)callback;
+ (void)setText:(NSString*)node :(NSString*)text;
+ (void)webLoad:(NSString*)node :(JSValue *)callback;
+ (void)webScript:(NSString*)node :(NSString *)javascript :(JSValue *)callback;
+ (void)webLoadUrl:(NSString*)node :(NSString*)url;
+ (NSString*)webCurrentUrl:(NSString*)node;
+ (void)webForward:(NSString*)node;
+ (void)webRefresh:(NSString*)node;

+ (void)scrollDragged:(NSString*)node :(JSValue *)callback;
+ (void)scrollEnd:(NSString*)node :(JSValue *)callback;
+ (void)textChanged:(NSString*)node :(JSValue *)callback;
+ (void)textFocusChanged:(NSString*)node :(JSValue *)callback;
+ (void)videoViewAutoPlay;
+ (void)videoCallback:(NSString*)nodeName :(NSString*)event :(JSValue*)callback;
+ (void)getCurrentLocation:(NSDictionary*)param :(JSValue*)callback;
+ (void)getCurrentPlace:(NSDictionary*)param :(JSValue*)callback;
+ (void)searchPlace:(NSDictionary*)param :(JSValue*)callback;
+ (JSValue*)parseUrl:(NSString*)url;
+ (void)menuReady:(NSString*)node :(NSDictionary*)param;
+ (void)menuOpen:(NSString*)node;
+ (void)menuClose;
+ (void)drawerOpen:(NSString*)node;
+ (void)drawerClose:(NSString*)node;
+ (void)drawerMove:(NSString*)node :(int)offset;
+ (void)drawerCallback:(NSString*)node: (NSString*)command :(JSValue *)callback;
+ (void)setTimer:(NSString*)key :(int)milli_sec :(JSValue*)callback;
+ (void)removeTimer:(NSString*)key;
+ (void)beaconScan:(NSDictionary*)param :(JSValue*)callback :(JSValue*)foundCallback;
+ (void)beaconStop;
+ (void)createDeepLink:(NSDictionary*)param :(JSValue*)callback;
+ (NSString*)getReserveUrl;
+ (NSString*)popReserveUrl;
+ (BOOL)consumeStandardReserveUrl;
+ (BOOL)standardUrlProcess:(NSString*)url;
+ (void)localPush:(id)param;
+ (void)toJpg:(NSString*)node :(JSValue*)callback;
+ (void)androidEscapeDozeModeIf:(NSString*)msg:(NSString*)yes:(NSString*)no;
+ (void)video:(NSDictionary*)param;
+ (void)photo:(NSDictionary*)param;
+ (void)timer:(NSString*)node :(int)sec;
+ (void)custom:(NSString*)function;
+ (void)bleList:(NSDictionary*)param :(JSValue *)callback;
+ (void)bleConnect:(NSString*)udid;
+ (void)bleDisconnect:(NSString*)udid;
+ (void)bleRelease:(NSString*)udid;
+ (void)bleCallback:(NSString*)command :(JSValue *)callback;
+ (void)bleWrite:(NSDictionary*)param :(JSValue*)callback;
+ (void)bleRead:(NSDictionary*)param :(JSValue*)callback;
+ (void)bleWriteDescriptor:(NSDictionary*)param :(JSValue*)callback;
+ (void)bleReadDescriptor:(NSDictionary*)param :(JSValue*)callback;
+ (void)fileChooser:(NSDictionary*)param :(JSValue*)callback;
+ (void)pdfInfo:(NSString*)url :(JSValue*)callback;
+ (void)pdfToImage:(NSString*)url :(NSDictionary*)param :(JSValue*)callback;
+ (void)imageMapCallback:(NSString*)nodeName :(NSString*)command :(JSValue*)callback;
+ (void)imageMapLocation:(NSString*)nodeName :(NSString*)key :(JSValue*)callback;
+ (void)imageMapMode:(NSString*)nodeName :(NSString*)mode :(NSDictionary*)param;
+ (void)imageMapFocus:(NSString*)nodeName :(NSString*)pinKey;
+ (void)imageMapConfig:(NSString*)nodeName : (NSDictionary*)param;
+ (NSString*)getByte:(NSString*)text;
+ (void)configHost:(NSString*)host;
+ (void)log:(NSString*)text:(NSDictionary*)log;
+ (NSString*)sha256:(NSString*)text;
+ (NSString*)sha256ToHex:(NSString*)text;
+ (NSString*)sha256ToHash:(NSString*)text;
+ (NSString*)sha512ToHash:(NSString*)text;
+ (void)gaEvent:(NSDictionary*)param;
+ (BOOL)isScreenOrientationLandscape;
+ (BOOL)isTablet;
+ (void)previewProject:(NSString *)project_id :(NSString *)start_screen_id :(NSString *)version;

+ (void)mapCamera:(NSString*)nodeName :(id)param :(JSValue*)callback;
+ (void)mapAddMarker:(NSString*)nodeName :(id)param :(JSValue*)callback;
+ (void)mapAddMarkers:(NSString*)nodeName :(id)param :(JSValue*)callback;
+ (void)mapUpdateMarker:(NSString*)nodeName :(id)param :(JSValue*)callback;
+ (void)mapUpdateMarkers:(NSString*)nodeName :(id)param :(JSValue*)callback;
+ (void)mapRemoveMarker:(NSString*)nodeName :(NSString*)key;
+ (void)mapAddCircle:(NSString*)nodeName :(id)param :(JSValue*)callback;
+ (void)mapRemoveCircle:(NSString*)nodeName :(NSString*)key;
+ (void)mapCallback:(NSString*)nodeName :(NSString*)event :(JSValue*)callback;
@end

@interface Jevil : NSObject <Jevil>

@end

NS_ASSUME_NONNULL_END
