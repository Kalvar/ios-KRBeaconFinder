//
//  KRBeaconFinder.h
//  KRBeaconFinder V1.0
//
//  Created by Kalvar on 2014/4/1.
//  Copyright (c) 2014年 Kalvar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "KRBeaconCentralManager.h"
#import "KRBeaconPeripheralManager.h"

@class CLLocationManager;
@class CLBeaconRegion;

typedef void(^FoundBeaconsHandler) (NSArray *foundBeacons, CLBeaconRegion *beaconRegion);

@interface KRBeaconFinder : NSObject
{
    
}

//Your Apple Certificated Beacon ID
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *identifier;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) NSArray *foundBeacons;

@property (nonatomic, assign) BOOL notifyEntryStateOnDisplay;
@property (nonatomic, assign) BOOL notifyOnEntry;
@property (nonatomic, assign) BOOL notifyOnExit;

@property (nonatomic, copy) FoundBeaconsHandler foundBeaconsHandler;

@property (nonatomic, strong) KRBeaconCentralManager *beaconCentralManager;
@property (nonatomic, strong) KRBeaconPeripheralManager *beaconPeripheralManager;
@property (nonatomic, copy) ScanningEnumerator bleScanningEnumerator;

#pragma --mark Blick Setters
-(void)setFoundBeaconsHandler:(FoundBeaconsHandler)_theFoundBeaconsHandler;
-(void)setBleScanningEnumerator:(ScanningEnumerator)_theBleScanningEnumerator;

#pragma --mark Public Methods
+(instancetype)sharedFinder;
-(instancetype)init;
-(void)ranging;
-(void)stopRanging;

#pragma --mark BLE Public Methods
-(void)bleScan;
-(void)bleStopScan;
-(void)bleAdversting;
-(void)bleStopAdversting;

@end
