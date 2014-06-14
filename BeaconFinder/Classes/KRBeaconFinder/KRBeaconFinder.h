//
//  KRBeacons.h
//  KRBeaconFinder V1.3
//
//  Created by Kalvar on 2013/07/01.
//  Copyright (c) 2013 - 2014年 Kalvar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "KRBeaconCentral.h"
#import "KRBeaconPeripheral.h"

typedef enum KRBeaconNotifyModes
{
    //0 0 0
    KRBeaconNotifyModeDeny = 0,
    //1 0 0
    KRBeaconNotifyModeOnlyDisplay,
    //0 1 0
    KRBeaconNotifyModeOnlyEntry,
    //1 1 0
    KRBeaconNotifyModeDisplayAndEntry,
    //0 0 1
    KRBeaconNotifyModeOnlyExit,
    //1 0 1
    KRBeaconNotifyModeDisplayAndExit,
    //0 1 1
    KRBeaconNotifyModeEntryAndExit,
    //1 1 1
    KRBeaconNotifyModeDefault
}KRBeaconNotifyModes;

@class CLLocationManager;
@class CLBeaconRegion;

typedef void(^FoundBeaconsHandler) (NSArray *foundBeacons, CLBeaconRegion *beaconRegion);
typedef void(^EnterRegionHandler) (CLLocationManager *manager, CLRegion *region);
typedef void(^ExitRegionHandler) (CLLocationManager *manager, CLRegion *region);
typedef void(^DisplayRegionHandler) (CLLocationManager *manager, CLRegion *region, CLRegionState state);

@protocol KRBeaconFinderDelegate;

@interface KRBeaconFinder : NSObject
{
    
}

@property (nonatomic, strong) id<KRBeaconFinderDelegate> delegate;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *foundBeacons;
@property (nonatomic, strong) NSArray *rangedRegions;
@property (nonatomic, strong) NSArray *monitoredRegions;

//regions will use for ranging and monitoring more different regions of beacon.
@property (nonatomic, strong) NSMutableArray *regions;

@property (nonatomic, copy) FoundBeaconsHandler foundBeaconsHandler;
@property (nonatomic, copy) EnterRegionHandler enterRegionHandler;
@property (nonatomic, copy) ExitRegionHandler exitRegionHandler;
@property (nonatomic, copy) DisplayRegionHandler displayRegionHandler;

@property (nonatomic, strong) KRBeaconCentral *beaconCentral;
@property (nonatomic, strong) KRBeaconPeripheral *beaconPeripheral;
@property (nonatomic, copy) ScanningEnumerator bleScanningEnumerator;

#pragma --mark Block Setters
-(void)setFoundBeaconsHandler:(FoundBeaconsHandler)_theBlock;
-(void)setBleScanningEnumerator:(ScanningEnumerator)_theBlock;
-(void)setEnterRegionHandler:(EnterRegionHandler)_theBlock;
-(void)setExitRegionHandler:(ExitRegionHandler)_theBlock;
-(void)setDisplayRegionHandler:(DisplayRegionHandler)_theBlock;

#pragma --mark Public Methods
+(instancetype)sharedFinder;
-(instancetype)init;

#pragma --mark Add Region Methods
-(void)addRegionWithUuid:(NSString *)_beaconUuid identifier:(NSString *)_beaconIdentifier major:(NSInteger)_beaconMajor minor:(NSInteger)_beaconMinor notifyMode:(KRBeaconNotifyModes)_notifyMode;
-(void)addRegionWithUuid:(NSString *)_beaconUuid identifier:(NSString *)_beaconIdentifier major:(NSInteger)_beaconMajor;
-(void)addRegionWithUuid:(NSString *)_beaconUuid identifier:(NSString *)_beaconIdentifier;
-(void)addRegion:(CLBeaconRegion *)_beaconRegion;

#pragma --mark Ranging Methods
-(BOOL)availableRangeBeacon;
-(void)ranging;
-(void)stopRanging;

#pragma --mark Monitoring Methods
-(BOOL)availableMonitorBeacon;
-(void)monitoring;
-(void)stopMonitoring;
-(void)requestState;
-(void)awakeDisplayWithRequestCompletion:(DisplayRegionHandler)_completion;
-(void)awakeDisplay;

#pragma --mark BLE Public Methods
-(void)bleScan;
-(void)bleStopScan;
-(void)bleAdversting;
-(void)bleStopAdversting;

#pragma --mark Relax Public Methods
-(void)fireLocalNotificationWithMessage:(NSString *)_message;
-(void)fireLocalNotificationWithMessage:(NSString *)_message userInfo:(NSDictionary *)_userInfo;

@end

@protocol KRBeaconFinderDelegate <NSObject>

@optional
-(void)krBeaconFinder:(KRBeaconFinder *)beaconFinder didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region;

@end
