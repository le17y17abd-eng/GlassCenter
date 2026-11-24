#import "GCSystem.h"
#import "GCPrivate.h"
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>
#import <dlfcn.h>

@implementation GCSystem

+ (void)initialize {
    if (self == [GCSystem class]) {
        dlopen("/System/Library/PrivateFrameworks/MobileBluetooth.framework/MobileBluetooth", RTLD_LAZY);
    }
}

+ (BOOL)airplane {
    SBAirplaneModeController *c = [objc_getClass("SBAirplaneModeController") sharedInstance];
    return [c respondsToSelector:@selector(isInAirplaneMode)] ? [c isInAirplaneMode] : NO;
}
+ (void)setAirplane:(BOOL)on {
    SBAirplaneModeController *c = [objc_getClass("SBAirplaneModeController") sharedInstance];
    if ([c respondsToSelector:@selector(setInAirplaneMode:)]) [c setInAirplaneMode:on];
}

+ (BOOL)wifi {
    SBWiFiManager *w = [objc_getClass("SBWiFiManager") sharedInstance];
    return [w respondsToSelector:@selector(wiFiEnabled)] ? [w wiFiEnabled] : NO;
}
+ (void)setWifi:(BOOL)on {
    SBWiFiManager *w = [objc_getClass("SBWiFiManager") sharedInstance];
    if ([w respondsToSelector:@selector(setWiFiEnabled:)]) [w setWiFiEnabled:on];
}

+ (BOOL)bluetooth {
    BluetoothManager *b = [objc_getClass("BluetoothManager") sharedInstance];
    return [b respondsToSelector:@selector(enabled)] ? [b enabled] : NO;
}
+ (void)setBluetooth:(BOOL)on {
    BluetoothManager *b = [objc_getClass("BluetoothManager") sharedInstance];
    if ([b respondsToSelector:@selector(setEnabled:)]) [b setEnabled:on];
    if ([b respondsToSelector:@selector(setPowered:)]) [b setPowered:on];
}

+ (BOOL)torch {
    AVCaptureDevice *d = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    return d.hasTorch && d.torchMode == AVCaptureTorchModeOn;
}
+ (void)setTorch:(BOOL)on {
    AVCaptureDevice *d = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (d.hasTorch && [d lockForConfiguration:nil]) {
        d.torchMode = on ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
        [d unlockForConfiguration];
    }
}

+ (BOOL)lowPower { return NSProcessInfo.processInfo.lowPowerModeEnabled; }
+ (void)setLowPower:(BOOL)on {
    _CDBatterySaver *s = [objc_getClass("_CDBatterySaver") batterySaver];
    if ([s respondsToSelector:@selector(setPowerMode:error:)]) [s setPowerMode:(on ? 1 : 0) error:nil];
}

+ (BOOL)rotationLocked {
    SBOrientationLockManager *m = [objc_getClass("SBOrientationLockManager") sharedInstance];
    return [m respondsToSelector:@selector(isUserLocked)] ? [m isUserLocked] : NO;
}
+ (void)setRotationLocked:(BOOL)on {
    SBOrientationLockManager *m = [objc_getClass("SBOrientationLockManager") sharedInstance];
    if (on && [m respondsToSelector:@selector(lock)]) [m lock];
    if (!on && [m respondsToSelector:@selector(unlock)]) [m unlock];
}

+ (float)volume {
    float v = 0;
    AVSystemController *c = [objc_getClass("AVSystemController") sharedAVSystemController];
    [c getVolume:&v forCategory:@"Audio/Video"];
    return v;
}
+ (void)setVolume:(float)volume {
    AVSystemController *c = [objc_getClass("AVSystemController") sharedAVSystemController];
    [c setVolumeTo:volume forCategory:@"Audio/Video"];
}

+ (void)openApp:(NSString *)bundleID {
    LSApplicationWorkspace *ws = [objc_getClass("LSApplicationWorkspace") defaultWorkspace];
    if ([ws respondsToSelector:@selector(openApplicationWithBundleID:)]) [ws openApplicationWithBundleID:bundleID];
}

+ (void)lockDevice {
    SBLockScreenManager *m = [objc_getClass("SBLockScreenManager") sharedInstance];
    if ([m respondsToSelector:@selector(lockUIFromSource:withOptions:)]) [m lockUIFromSource:1 withOptions:nil];
}

+ (void)respring { exit(0); } // launchd relaunches SpringBoard

@end
