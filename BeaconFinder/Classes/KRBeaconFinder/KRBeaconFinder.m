//
//  KRBeacons.m
//  KRBeaconFinder V1.5
//
//  Created by Kalvar on 2013/07/01.
//  Copyright (c) 2013 - 2014年 Kalvar. All rights reserved.
//

#import "KRBeaconFinder.h"

@interface KRBeaconFinder ()<CLLocationManagerDelegate>


@end

@implementation KRBeaconFinder (fixRegions)

-(CLBeaconRegion *)_makeBeaconRegionWithUuid:(NSString *)_beaconUuid identifier:(NSString *)_beaconIdentifier major:(NSInteger)_beaconMajor minor:(NSInteger)_beaconMinor notifyMode:(KRBeaconNotifyModes)_notifyMode
{
    CLBeaconRegion *_beaconRegion = nil;
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:_beaconUuid];
    if( _beaconMajor > 0 && _beaconMinor > 0 )
    {
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID
                                                                major:_beaconMajor
                                                                minor:_beaconMinor
                                                           identifier:_beaconIdentifier];
    }
    else
    {
        if( _beaconMajor > 0 )
        {
            _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID
                                                                    major:_beaconMajor
                                                               identifier:_beaconIdentifier];
        }
        else
        {
            _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:_beaconIdentifier];
        }
    }
    
    if( _beaconRegion )
    {
        BOOL _notifyDisplay = YES;
        BOOL _notifyEntry   = YES;
        BOOL _notifyExit    = YES;
        switch (_notifyMode)
        {
            case KRBeaconNotifyModeDeny:
                _notifyDisplay = NO;
                _notifyEntry   = NO;
                _notifyExit    = NO;
                break;
            case KRBeaconNotifyModeOnlyDisplay:
                _notifyEntry   = NO;
                _notifyExit    = NO;
                break;
            case KRBeaconNotifyModeOnlyEntry:
                _notifyDisplay = NO;
                _notifyExit    = NO;
                break;
            case KRBeaconNotifyModeOnlyExit:
                _notifyDisplay = NO;
                _notifyEntry   = NO;
                break;
            case KRBeaconNotifyModeDisplayAndEntry:
                _notifyExit    = NO;
                break;
            case KRBeaconNotifyModeDisplayAndExit:
                _notifyEntry   = NO;
                break;
            case KRBeaconNotifyModeEntryAndExit:
                _notifyDisplay = NO;
                break;
            default:
                //KRBeaconNotifyModeDefault
                break;
        }
        _beaconRegion.notifyEntryStateOnDisplay = _notifyDisplay;
        _beaconRegion.notifyOnEntry             = _notifyEntry;
        _beaconRegion.notifyOnExit              = _notifyExit;
    }
    
    return _beaconRegion;
}

@end

@implementation KRBeaconFinder (fixLocations)

-(void)_buildLocationManager
{
    if( !self.locationManager )
    {
        self.locationManager                 = [[CLLocationManager alloc] init];
        self.locationManager.delegate        = self;
        self.locationManager.activityType    = CLActivityTypeFitness;
        self.locationManager.distanceFilter  = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
}

@end

@implementation KRBeaconFinder (fixNotifications)

-(void)_fireLocalNotificationWithMessage:(NSString *)_message userInfo:(NSDictionary *)_userInfo
{
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertBody            = _message;
    notification.userInfo             = _userInfo;
    //App 如運行在前台，則會直接進入本地通知的委派裡，如運行在後台，則會直接出現通知在螢幕上
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

-(void)_fireLocalNotificationWithMessage:(NSString *)_message
{
    [self _fireLocalNotificationWithMessage:_message userInfo:nil];
}

@end

@implementation KRBeaconFinder

@synthesize delegate                  = _delegate;

@synthesize locationManager           = _locationManager;
@synthesize foundBeacons              = _foundBeacons;

@synthesize rangedRegions             = _rangedRegions;
@synthesize monitoredRegions          = _monitoredRegions;

@synthesize isRanging                 = _isRanging;
@synthesize isMonitoring              = _isMonitoring;
@synthesize adverstingRegion          = _adverstingRegion;

@synthesize foundBeaconsHandler       = _foundBeaconsHandler;
@synthesize enterRegionHandler        = _enterRegionHandler;
@synthesize exitRegionHandler         = _exitRegionHandler;
@synthesize displayRegionHandler      = _displayRegionHandler;

@synthesize beaconCentral             = _beaconCentral;
@synthesize beaconPeripheral          = _beaconPeripheral;
@synthesize bleScanningEnumerator     = _bleScanningEnumerator;

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
        _delegate                  = nil;
        
        _beaconCentral             = [KRBeaconCentral sharedCentral];
        _beaconPeripheral          = [KRBeaconPeripheral sharedPeripheral];
        
        _foundBeacons              = nil;
        _isRanging                 = YES;
        _isMonitoring              = YES;
        _adverstingRegion          = nil;
        
        _foundBeaconsHandler       = nil;
        _enterRegionHandler        = nil;
        _exitRegionHandler         = nil;
        _displayRegionHandler      = nil;
        _bleScanningEnumerator     = nil;
        
        [self _buildLocationManager];
    }
    return self;
}

#pragma --mark Add Region Methods
-(void)addRegionWithUuid:(NSString *)_beaconUuid identifier:(NSString *)_beaconIdentifier major:(NSInteger)_beaconMajor minor:(NSInteger)_beaconMinor notifyMode:(KRBeaconNotifyModes)_notifyMode
{
    if( !_regions )
    {
        _regions = [NSMutableArray new];
    }
    CLBeaconRegion *_beaconRegion = [self _makeBeaconRegionWithUuid:_beaconUuid
                                                         identifier:_beaconIdentifier
                                                              major:_beaconMajor
                                                              minor:_beaconMinor
                                                         notifyMode:_notifyMode];
    if( _beaconRegion )
    {
        [_regions addObject:[_beaconRegion copy]];
        _beaconRegion = nil;
    }
}

-(void)addRegionWithUuid:(NSString *)_beaconUuid identifier:(NSString *)_beaconIdentifier major:(NSInteger)_beaconMajor
{
    [self addRegionWithUuid:_beaconUuid identifier:_beaconIdentifier major:_beaconMajor minor:-1 notifyMode:KRBeaconNotifyModeDefault];
}

-(void)addRegionWithUuid:(NSString *)_beaconUuid identifier:(NSString *)_beaconIdentifier
{
    [self addRegionWithUuid:_beaconUuid identifier:_beaconIdentifier major:-1 minor:-1 notifyMode:KRBeaconNotifyModeDefault];
}

-(void)addRegion:(CLBeaconRegion *)_beaconRegion
{
    if( !_regions )
    {
        _regions = [NSMutableArray new];
    }
    [_regions addObject:[_beaconRegion copy]];
    _beaconRegion = nil;
}

#pragma --mark Remove Region Methods
-(void)removeRegion:(CLBeaconRegion *)_beaconRegion
{
    if( _regions )
    {
        //如果存在就直接刪除
        if( [_regions containsObject:_beaconRegion] )
        {
            [_regions removeObject:_beaconRegion];
            [_locationManager stopRangingBeaconsInRegion:_beaconRegion];
            [_locationManager stopMonitoringForRegion:_beaconRegion];
        }
        else
        {
            //如果不存在就執行 Double Check 進行刪除的動作
            [self removeRegionWithUuid:_beaconRegion.proximityUUID.UUIDString
                            identifier:_beaconRegion.identifier
                                 major:_beaconRegion.major.integerValue
                                 minor:_beaconRegion.minor.integerValue];
        }
    }
}

-(void)removeRegionWithUuid:(NSString *)_beaconUuid identifier:(NSString *)_beaconIdentifier major:(NSInteger)_beaconMajor minor:(NSInteger)_beaconMinor
{
    if( _regions )
    {
        //如果不存在就執行 Double Check 進行刪除的動作
        NSMutableArray *_tempRegions = [_regions copy];
        for( CLBeaconRegion *_everyRegion in _tempRegions )
        {
            //如果 (NSNumber *) Major, Minor 是 nil, 則 integerValue 會是 0
            if( [_everyRegion.proximityUUID.UUIDString isEqualToString:_beaconUuid] &&
                [_everyRegion.identifier isEqualToString:_beaconIdentifier] &&
                _everyRegion.major.integerValue == _beaconMajor &&
                _everyRegion.minor.integerValue == _beaconMinor )
            {
                [_regions removeObject:_everyRegion];
                [_locationManager stopRangingBeaconsInRegion:_everyRegion];
                [_locationManager stopMonitoringForRegion:_everyRegion];
                //break;
            }
        }
        [_tempRegions removeAllObjects];
        _tempRegions = nil;
    }
}

-(void)removeRegionWithUuid:(NSString *)_beaconUuid identifier:(NSString *)_beaconIdentifier major:(NSInteger)_beaconMajor
{
    [self removeRegionWithUuid:_beaconUuid
                    identifier:_beaconIdentifier
                         major:_beaconMajor
                         minor:0];
}

-(void)removeRegionWithUuid:(NSString *)_beaconUuid identifier:(NSString *)_beaconIdentifier
{
    [self removeRegionWithUuid:_beaconUuid
                    identifier:_beaconIdentifier
                         major:0];
}

#pragma --mark Create Adversting Beacon Region Methods
-(void)createAdvertisingRegionWithUuid:(NSString *)_uuid identifier:(NSString *)_identifier major:(NSUInteger)_major minor:(NSUInteger)_minor
{
    self.adverstingRegion = [self _makeBeaconRegionWithUuid:_uuid
                                                 identifier:_identifier
                                                      major:_major
                                                      minor:_minor
                                                 notifyMode:KRBeaconNotifyModeDefault];
}

#pragma --mark Ranging Methods
/*
 * @ 允許搜索 iBeacons( Allows Ranging BeaconRegions )
 */
-(BOOL)canRangeBeacon
{
    if( !_locationManager )
    {
        [self _buildLocationManager];
    }
    
    if ( ![CLLocationManager isRangingAvailable] )
    {
        return NO;
    }
    
    if( [_regions count] < 1 )
    {
        return NO;
    }
    
    return YES;
}

-(void)rangingWithBeaconsFounder:(FoundBeaconsHandler)_founder
{
    self.foundBeaconsHandler = _founder;
    if( [self canRangeBeacon] )
    {
        [self stopRanging];
        _isRanging = YES;
        for( CLBeaconRegion *_everyRegion in _regions )
        {
            [_locationManager startRangingBeaconsInRegion:_everyRegion];
        }
        //取得正在監控的 Region
        //[_locationManager.monitoredRegions member:_beaconRegion];
    }
}

/*
 * @ 開始範圍搜索多顆 Beacons
 */
-(void)ranging
{
    [self rangingWithBeaconsFounder:_foundBeaconsHandler];
}

/*
 * @ 停止範圍搜索多顆 Beacons
 */
-(void)stopRanging
{
    _isRanging = NO;
    //沒有監控的 Regions
    if (_locationManager.rangedRegions.count == 0)
    {
        return;
    }
    if( [_regions count] > 0 )
    {
        for( CLBeaconRegion *_everyRegion in _regions )
        {
            [_locationManager stopRangingBeaconsInRegion:_everyRegion];
        }
    }
    self.foundBeacons = nil;
}

#pragma --mark Monitoring Methods
-(BOOL)canMonitorBeacon
{
    if( !_locationManager )
    {
        [self _buildLocationManager];
    }
    
    //Device 支援監控 BeaconRegion 的話
    if ( ![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]] )
    {
        return NO;
    }
    
    if( [_regions count] < 1 )
    {
        return NO;
    }
    
    return YES;
}

-(void)monitoringWithDisplayHandler:(DisplayRegionHandler)_handler
{
    self.displayRegionHandler = _handler;
    if( [self canMonitorBeacon] )
    {
        [self stopMonitoring];
        _isMonitoring = YES;
        for( CLBeaconRegion *_everyRegion in _regions )
        {
            [_locationManager startMonitoringForRegion:_everyRegion];
        }
    }
}

/*
 * @ 開始監控 Beacons
 */
-(void)monitoring
{
    [self monitoringWithDisplayHandler:_displayRegionHandler];
}

/*
 * @ 停止監控 Beacons
 */
-(void)stopMonitoring
{
    _isMonitoring = NO;
    if( [_regions count] > 0 )
    {
        for( CLBeaconRegion *_everyRegion in _regions )
        {
            [_locationManager stopMonitoringForRegion:_everyRegion];
        }
    }
}

/*
 * @ 請求立即進入 locationManager:didDetermineState:forRegion: 委派方法
 *   - 如此才能在背景移除 App 並鎖屏時，收到通知 ?
 *     - Ans : 不對，這函式是立即觸發該委派方法，作用就像 [NSTimer fire] 的意思一樣，
 *             即使不執行此 requestStateForRegion 的方法，也能正確的在執行 Monitoring 時，被正確的觸發。
 */
-(void)requestState
{
    if( [self canMonitorBeacon] )
    {
        for( CLBeaconRegion *_everyRegion in _regions )
        {
            [_locationManager requestStateForRegion:_everyRegion];
            break;
        }
    }
}

/*
 * @ 喚醒鎖屏顯示
 *   - 必須在 AppDelegate 的 didFinishLaunchingWithOptions 方法裡呼叫此方法，
 *     這樣才能在背景移除 App 時，能正確收到通知。
 *
 *   - 須注意，一定要在 AppDelegate 裡啟動 [_locationManager startMonitoringForRegion:] 監控，
 *     這樣才會正確的在實作監控 iBeacons 背景移除並鎖屏的功能時，
 *     順利能進到 locationManager:didDetermineState:forRegion: 委派方法裡。
 *
 */
-(void)awakeDisplayWithFoundCompletion:(DisplayRegionHandler)_completion
{
    self.displayRegionHandler = _completion;
    if( [self canMonitorBeacon] )
    {
        [self monitoring];
        //[self requestState];
    }
}

-(void)awakeDisplay
{
    [self awakeDisplayWithFoundCompletion:_displayRegionHandler];
}

#pragma --mark BLE Public Methods
-(void)bleScan
{
    [_beaconCentral scan];
}

-(void)bleStopScan
{
    [_beaconCentral stopScan];
}

-(void)bleAdversting
{
    [_beaconPeripheral advertising];
}

-(void)bleStopAdversting
{
    [_beaconPeripheral stopAdvertising];
}

#pragma --mark Relax Public Methods
-(void)fireLocalNotificationWithMessage:(NSString *)_message
{
    [self _fireLocalNotificationWithMessage:_message];
}

-(void)fireLocalNotificationWithMessage:(NSString *)_message userInfo:(NSDictionary *)_userInfo
{
    [self _fireLocalNotificationWithMessage:_message userInfo:_userInfo];
}

#pragma --mark Block Setters
-(void)setFoundBeaconsHandler:(FoundBeaconsHandler)_theBlock
{
    _foundBeaconsHandler   = _theBlock;
}

-(void)setBleScanningEnumerator:(ScanningEnumerator)_theBlock
{
    _bleScanningEnumerator = _theBlock;
    if( _beaconCentral )
    {
        _beaconCentral.scanningEnumerator = _bleScanningEnumerator;
    }
}

-(void)setEnterRegionHandler:(EnterRegionHandler)_theBlock
{
    _enterRegionHandler    = _theBlock;
}

-(void)setExitRegionHandler:(ExitRegionHandler)_theBlock
{
    _exitRegionHandler     = _theBlock;
}

-(void)setDisplayRegionHandler:(DisplayRegionHandler)_theBlock
{
    _displayRegionHandler  = _theBlock;
}

#pragma --mark Setters
-(void)setAdverstingRegion:(CLBeaconRegion *)_theAdverstingRegion
{
    _adverstingRegion = _theAdverstingRegion;
    //同步設定 beaconPeripheral 要廣播的 beaconRegion
    if( self.beaconPeripheral )
    {
        _beaconPeripheral.beaconRegion = _adverstingRegion;
    }
}

#pragma --mark Getters
-(NSArray *)rangedRegions
{
    if( _locationManager )
    {
        return [_locationManager.rangedRegions allObjects];
    }
    return nil;
}

-(NSArray *)monitoredRegions
{
    if( _locationManager )
    {
        return [_locationManager.monitoredRegions allObjects];
    }
    return nil;
}

#pragma --mark Beacon ranging delegate methods
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
    NSLog(@"beacons 1 : %@", beacons);
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
     *   - major     是 該 Beacons 群組 ID，當接收到 uuid 判斷為可以作動的 Beacons 後，就依照 major 來判斷是要做什麼類型的事情 ( major likes category #. )
     *   - minor     是 該 Beacons 群組底下，每一顆 Beacon 可以做什麼事情的判斷 ID ( use the minor number to do what you do. )
     *   - accuracy  會顯示目前 Beacon 離 iPhone 多遠，單位是公尺( meter )，not proximity
     *   - rssi      會顯示目前的訊號強度，越近則越大，越遠則越小，範圍從 -43 ~ -94 以內為可信區域 ( trust scopes )
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

/*
 * A user can transition in or out of a region while the application is not running. When this happens CoreLocation will launch the application momentarily, call this delegate method and we will let the user know via a local notification.
 *
 * 用戶可以在應用程序沒有運行或縮小一個區域的時，CoreLocation 將啟動應用程序瞬間調用此委託的方法，將通過本地通知讓用戶知道，包含鎖屏時也能收到通知。
 *
 */
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if( self.delegate )
    {
        if( [_delegate respondsToSelector:@selector(krBeaconFinder:didDetermineState:forRegion:)] )
        {
            [_delegate krBeaconFinder:self didDetermineState:state forRegion:region];
        }
    }
    
    if( self.displayRegionHandler )
    {
        _displayRegionHandler(manager, region, state);
    }
}


@end
