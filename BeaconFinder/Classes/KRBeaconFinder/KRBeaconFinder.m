//
//  KRBeaconFinder.m
//  KRBeaconFinder V1.1
//
//  Created by Kalvar on 2014/4/1.
//  Copyright (c) 2014年 Kalvar. All rights reserved.
//

#import "KRBeaconFinder.h"
#import <CoreLocation/CoreLocation.h>

@interface KRBeaconFinder ()<CLLocationManagerDelegate>


@end

@implementation KRBeaconFinder (fixBeacons)

- (void)_createBeaconRegion
{
    if (self.beaconRegion)
    {
        return;
    }
    
    //proximityUUID 指的是該 Apple Certificated Beacon ID，而不是 BLE 掃出來的 DeviceUUID
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:self.uuid];
    self.beaconRegion     = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:self.identifier];
    self.beaconRegion.notifyEntryStateOnDisplay = self.notifyEntryStateOnDisplay;
    self.beaconRegion.notifyOnEntry             = self.notifyOnEntry;
    self.beaconRegion.notifyOnExit              = self.notifyOnExit;
    //self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID major:18527 minor:23618 identifier:kIdentifier];
}

@end

@implementation KRBeaconFinder (fixLocations)

- (void)_buildLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate        = self;
    self.locationManager.activityType    = CLActivityTypeFitness;
    self.locationManager.distanceFilter  = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
}

@end

@implementation KRBeaconFinder (fixNotifications)

-(void)_fireLocalNotificationWithMessage:(NSString *)_message
{
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertBody            = _message;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

@end

@implementation KRBeaconFinder

@synthesize uuid                      = _uuid;
@synthesize identifier                = _identifier;

@synthesize locationManager           = _locationManager;
@synthesize beaconRegion              = _beaconRegion;
@synthesize foundBeacons              = _foundBeacons;

@synthesize notifyEntryStateOnDisplay = _notifyEntryStateOnDisplay;
@synthesize notifyOnEntry             = _notifyOnEntry;
@synthesize notifyOnExit              = _notifyOnExit;

@synthesize foundBeaconsHandler       = _foundBeaconsHandler;
@synthesize enterRegionHandler        = _enterRegionHandler;
@synthesize exitRegionHandler         = _exitRegionHandler;

@synthesize beaconCentralManager      = _beaconCentralManager;
@synthesize beaconPeripheralManager   = _beaconPeripheralManager;

+(instancetype)sharedFinder
{
    static dispatch_once_t pred;
    static KRBeaconFinder *_object = nil;
    dispatch_once(&pred, ^{
        _object = [[KRBeaconFinder alloc] init];
    });
    return _object;
}

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        _uuid       = nil;
        _identifier = nil;
        
        _notifyEntryStateOnDisplay = YES;
        _notifyOnEntry             = YES;
        _notifyOnExit              = YES;
        
        _beaconCentralManager      = [KRBeaconCentralManager sharedManager];
        _beaconPeripheralManager   = [KRBeaconPeripheralManager sharedManager];
        
        _foundBeaconsHandler       = nil;
        _enterRegionHandler        = nil;
        _exitRegionHandler         = nil;
        _bleScanningEnumerator     = nil;
        
        [self _buildLocationManager];
    }
    return self;
}

/*
 * @ 開始監控 iBeacons 的區域( BeaconRegions )
 */
-(void)ranging
{
    if( !_locationManager )
    {
        [self _buildLocationManager];
    }
    
    if ( ![CLLocationManager isRangingAvailable] )
    {
        return;
    }
    
    if ( _locationManager.rangedRegions.count > 0 )
    {
        return;
    }
    
    [self _createBeaconRegion];
    
    [_locationManager startRangingBeaconsInRegion:_beaconRegion];
    [_locationManager startMonitoringForRegion:_beaconRegion];
}

/*
 * @ 停止監控區域
 */
-(void)stopRanging
{
    //沒有監控的 Regions
    if (_locationManager.rangedRegions.count == 0)
    {
        return;
    }
    
    [_locationManager stopRangingBeaconsInRegion:_beaconRegion];
    [_locationManager stopMonitoringForRegion:_beaconRegion];
    self.foundBeacons = nil;
}

#pragma --mark BLE Public Methods
-(void)bleScan
{
    [_beaconCentralManager scan];
}

-(void)bleStopScan
{
    [_beaconCentralManager stopScan];
}

-(void)bleAdversting
{
    [_beaconPeripheralManager advertising];
}

-(void)bleStopAdversting
{
    [_beaconPeripheralManager stopAdvertising];
}

#pragma --mark Relax Public Methods
-(void)fireLocalNotificationWithMessage:(NSString *)_message
{
    [self _fireLocalNotificationWithMessage:_message];
}

#pragma --mark Block Setters
-(void)setFoundBeaconsHandler:(FoundBeaconsHandler)_theFoundBeaconsHandler
{
    _foundBeaconsHandler = _theFoundBeaconsHandler;
}

-(void)setBleScanningEnumerator:(ScanningEnumerator)_theBleScanningEnumerator
{
    _bleScanningEnumerator = _theBleScanningEnumerator;
    if( _beaconCentralManager )
    {
        _beaconCentralManager.scanningEnumerator = _bleScanningEnumerator;
    }
}

-(void)setEnterRegionHandler:(EnterRegionHandler)_theEnterRegionHandler
{
    _enterRegionHandler = _theEnterRegionHandler;
}

-(void)setExitRegionHandler:(ExitRegionHandler)_theExitRegionHandler
{
    _exitRegionHandler = _theExitRegionHandler;
}

#pragma --mark Setters
-(void)setNotifyEntryStateOnDisplay:(BOOL)_theNotifyEntryStateOnDisplay
{
    _notifyEntryStateOnDisplay = _theNotifyEntryStateOnDisplay;
    if( _beaconRegion )
    {
        _beaconRegion.notifyEntryStateOnDisplay = _notifyEntryStateOnDisplay;
    }
}

-(void)setNotifyOnEntry:(BOOL)_theNotifyOnEntry
{
    _notifyOnEntry = _theNotifyOnEntry;
    if( _beaconRegion )
    {
        _beaconRegion.notifyOnEntry = _notifyOnEntry;
    }
}

-(void)setNotifyOnExit:(BOOL)_theNotifyOnExit
{
    _notifyOnExit = _theNotifyOnExit;
    if( _beaconRegion )
    {
        _beaconRegion.notifyOnExit = _notifyOnExit;
    }
}

-(void)setBeaconRegion:(CLBeaconRegion *)_theBeaconRegion
{
    _beaconRegion = _theBeaconRegion;
    if( _beaconPeripheralManager )
    {
        _beaconPeripheralManager.beaconRegion = _beaconRegion;
    }
}

#pragma mark - Beacon ranging delegate methods
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (![CLLocationManager locationServicesEnabled])
    {
        return;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized)
    {
        return;
    }
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"beacons : %@", beacons);
    /*
     * @ Noted
     *   - 收到的 CLBeacon 訊息
     *     CLBeacon (uuid:<__NSConcreteUUID 0x146c6c80> B9407F30-F5F8-466E-AFF9-25556B57FE6D,
     *               major:18527,
     *               minor:23618,
     *               proximity:1 +/- 0.07m,
     *               rssi:-53)
     *
     *   - uuid      是 Apple Certificated Beacon ID，不同於 Device UUID
     *   - major     是 該 Beacons 群組 ID，當接收到 uuid 判斷為可以作動的 Beacons 後，就依照 major 來判斷是要做什麼類型的事情
     *   - minor     是 該 Beacons 群組底下，每一顆 Beacon 可以做什麼事情的判斷 ID
     *   - proximity 會顯示目前 Beacon 離 iPhone 多遠，單位是公尺( m )
     *   - rssi      會顯示目前的訊號強度，越近則越大，越遠則越小，範圍從 -43 ~ -94 以內為可信區域
     *
     */
    _foundBeacons = beacons;
    if( _foundBeaconsHandler )
    {
        self.foundBeaconsHandler(_foundBeacons, region);
    }
    
    //[self _fireLocalNotificationWithMessage:@"Found Beacon Notification"];
}

//When app enters the monitored iBeacon scope happen.
//當 iBeacons 進入區域時
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if( self.enterRegionHandler )
    {
        _enterRegionHandler(manager, region);
    }
    //[self _fireLocalNotificationWithMessage:@"Enter region notification"];
}

//When app exited the monitored iBeacon scope happen.
//當 iBeacons 離開區域時
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if( self.exitRegionHandler )
    {
        _exitRegionHandler(manager, region);
    }
    //[self _fireLocalNotificationWithMessage:@"Exit region notification"];
}

@end



