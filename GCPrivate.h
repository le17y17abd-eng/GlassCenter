// Private API declarations. All classes are looked up at runtime with objc_getClass.
#import <Foundation/Foundation.h>

@interface SBWiFiManager : NSObject
+ (instancetype)sharedInstance;
- (BOOL)wiFiEnabled;
- (void)setWiFiEnabled:(BOOL)enabled;
@end

@interface BluetoothManager : NSObject
+ (instancetype)sharedInstance;
- (BOOL)enabled;
- (void)setEnabled:(BOOL)enabled;
- (void)setPowered:(BOOL)powered;
@end

@interface SBAirplaneModeController : NSObject
+ (instancetype)sharedInstance;
- (BOOL)isInAirplaneMode;
- (void)setInAirplaneMode:(BOOL)mode;
@end

@interface SBOrientationLockManager : NSObject
+ (instancetype)sharedInstance;
- (BOOL)isUserLocked;
- (void)lock;
- (void)unlock;
@end

@interface SBLockScreenManager : NSObject
+ (instancetype)sharedInstance;
- (void)lockUIFromSource:(int)source withOptions:(id)options;
@end

@interface AVSystemController : NSObject
+ (instancetype)sharedAVSystemController;
- (BOOL)getVolume:(float *)volume forCategory:(NSString *)category;
- (BOOL)setVolumeTo:(float)volume forCategory:(NSString *)category;
@end

@interface _CDBatterySaver : NSObject
+ (instancetype)batterySaver;
- (long long)getPowerMode;
- (BOOL)setPowerMode:(long long)mode error:(NSError **)error;
@end

@interface LSApplicationWorkspace : NSObject
+ (instancetype)defaultWorkspace;
- (BOOL)openApplicationWithBundleID:(NSString *)bundleID;
@end
