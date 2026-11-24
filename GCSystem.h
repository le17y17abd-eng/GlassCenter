#import <Foundation/Foundation.h>

// Thin wrapper around the system controls (private APIs, all nil-safe).
@interface GCSystem : NSObject
+ (BOOL)airplane;        + (void)setAirplane:(BOOL)on;
+ (BOOL)wifi;            + (void)setWifi:(BOOL)on;
+ (BOOL)bluetooth;       + (void)setBluetooth:(BOOL)on;
+ (BOOL)torch;           + (void)setTorch:(BOOL)on;
+ (BOOL)lowPower;        + (void)setLowPower:(BOOL)on;
+ (BOOL)rotationLocked;  + (void)setRotationLocked:(BOOL)on;
+ (float)volume;         + (void)setVolume:(float)volume;
+ (void)openApp:(NSString *)bundleID;
+ (void)lockDevice;
+ (void)respring;
@end
