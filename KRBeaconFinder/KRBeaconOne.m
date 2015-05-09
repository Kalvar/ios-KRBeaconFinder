//
//  KRBeaconFinder.m
//  KRBeaconFinder V1.5
//
//  Created by Kalvar on 2013/07/01.
//  Copyright (c) 2013 - 2015年 Kalvar. All rights reserved.
//

#import "KRBeaconOne.h"

@interface KRBeaconOne ()<CLLocationManagerDelegate>


@end

@implementation KRBeaconOne (fixBeacons)

- (void)_createBeaconRegion
{
    if (self.beaconRegion)
    {
        return;
    }
    
    //proximityUUID 指的是該 Apple Certificated Beacon ID，而不是 BLE 掃出來的 DeviceUUID
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:self.uuid]; //[NSUUID UUID]
    if( self.major > 0 && self.minor > 0 )
    {
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID
                                                                    major:self.major
                                                                    minor:self.minor
                                                               identifier:self.identifier];
        /*
        //指定監控 Beacon + Major / Minor
        //這樣在 Enter Region, Exit Region, Monitor Region 時，才能取得該 BeaconRegion 的 Major / Minor
        self.beaconRegion     = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID
                                                                        major:18527
                                                                        minor:23618
                                                                   identifier:self.identifier];
        //*/
    }
    else
    {
        if( self.major > 0 )
        {
            self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID
                                                                        major:self.major
                                                                   identifier:self.identifier];
        }
        else
        {
            self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:self.identifier];
        }
    }
    
    self.beaconRegion.notifyEntryStateOnDisplay = self.notifyOnDisplay;
    self.beaconRegion.notifyOnEntry             = self.notifyOnEntry;
    self.beaconRegion.notifyOnExit              = self.notifyOnExit;
    
    if( self.beaconRegion )
    {
        [super addRegion:self.beaconRegion];
    }
}

@end

@implementation KRBeaconOne

@synthesize oneDelegate               = _oneDelegate;

@synthesize uuid                      = _uuid;
@synthesize identifier                = _identifier;
@synthesize major                     = _major;
@synthesize minor                     = _minor;

@synthesize beaconRegion              = _beaconRegion;

@synthesize notifyOnDisplay           = _notifyOnDisplay;
@synthesize notifyOnEntry             = _notifyOnEntry;
@synthesize notifyOnExit              = _notifyOnExit;
@synthesize notifyMode                = _notifyMode;

#pragma --mark Public Methods
+(instancetype)sharedFinder
{
    static dispatch_once_t pred;
    static KRBeaconOne *_object = nil;
    dispatch_once(&pred, ^{
        _object = [[KRBeaconOne alloc] init];
    });
    return _object;
}

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        _uuid                         = nil;
        _identifier                   = nil;
        _major                        = 0;
        _minor                        = 0;
        
        _notifyOnDisplay              = YES;
        _notifyOnEntry                = YES;
        _notifyOnExit                 = YES;
        
        _oneDelegate                  = nil;
        
        self.locationManager.delegate = self;
    }
    return self;
}

#pragma --mark Override Add Region Methods
-(void)addRegionWithUuid:(NSString *)_beaconUuid identifier:(NSString *)_beaconIdentifier major:(NSInteger)_beaconMajor minor:(NSInteger)_beaconMinor
{
    _uuid         = _beaconUuid;
    _identifier   = _beaconIdentifier;
    _major        = _beaconMajor;
    _minor        = _beaconMinor;
    _beaconRegion = nil;
    [self _createBeaconRegion];
}

#pragma --mark Override Ranging Methods
/*
 * @ 開始範圍搜索
 */
-(void)rangingWithBeaconsFounder:(FoundBeaconsHandler)_founder
{
    [self _createBeaconRegion];
    [super rangingWithBeaconsFounder:_founder];
}

-(void)ranging
{
    [self _createBeaconRegion];
    [super ranging];
}

/*
 * @ 停止範圍搜索與監控區域
 */
-(void)stopRanging
{
    [super stopRanging];
}

#pragma --mark Monitoring Methods
/*
 * @ 開始監控 Beacons
 */
-(void)monitoringWithDisplayHandler:(DisplayRegionHandler)_handler
{
    [self _createBeaconRegion];
    [super monitoringWithDisplayHandler:_handler];
}

-(void)monitoring
{
    [self _createBeaconRegion];
    [super monitoring];
}

/*
 * @ 停止監控 Beacons
 */
-(void)stopMonitoring
{
    [super stopMonitoring];
}

-(void)awakeDisplayWithFoundCompletion:(DisplayRegionHandler)_completion
{
    /*
     * @ 關於繼承的筆記
     *   - 如果本 KRBeaconOne 有自行實作 @synthesize displayRegionHandler; 就會重新 Override KRBeaconFinder 的 displayRegionHandler Block, 
     *     此時，displayRegionHandler 就會改在本 Class ( 子類別 ) 裡運作，而原先繼承父類別會啟動到 displayRegionHandler 的流程時機就會失效，
     *     這會造成機制的混亂。
     *
     *   - 如果想要實行父類別的運作流程，而在子類別就不去 Override 繼承的任何參數、變數、函式、Blocks 等，
     *     改成直接用 self.displayRegionHandler 的模式直接取用父類別的參數，並且再賦值或呼叫運作即可。
     *
     */
    //super.displayRegionHandler = _completion;
    self.displayRegionHandler = _completion;
    [self monitoring];
}

-(void)awakeDisplay
{
    //super.displayRegionHandler
    [self awakeDisplayWithFoundCompletion:self.displayRegionHandler];
}

#pragma --mark Setters
-(void)setNotifyOnDisplay:(BOOL)_theNotifyEntryStateOnDisplay
{
    _notifyOnDisplay = _theNotifyEntryStateOnDisplay;
    if( _beaconRegion )
    {
        _beaconRegion.notifyEntryStateOnDisplay = _notifyOnDisplay;
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
    //同步設定 beaconPeripheral 要廣播的 beaconRegion
    if( self.beaconPeripheral )
    {
        self.beaconPeripheral.beaconRegion = _beaconRegion;
    }
}

#pragma --mark Getters
-(KRBeaconNotifyModes)notifyMode
{
    /*
     * @ 演算法則
     *   - 1. 先將 KRBeaconNotifyModes 以 2 進制模式編排 :
     *
     *      //0 0 0
     *      KRBeaconNotifyModeDeny = 0,         //0
     *      //1 0 0
     *      KRBeaconNotifyModeOnlyDisplay,      //1
     *      //0 1 0
     *      KRBeaconNotifyModeOnlyEntry,        //2
     *      //1 1 0
     *      KRBeaconNotifyModeDisplayAndEntry,  //3
     *      //0 0 1
     *      KRBeaconNotifyModeOnlyExit,         //4
     *      //1 0 1
     *      KRBeaconNotifyModeDisplayAndExit,   //5
     *      //0 1 1
     *      KRBeaconNotifyModeEntryAndExit,     //6
     *      //1 1 1
     *      KRBeaconNotifyModeDefault           //7
     *
     *   - 2. 再將 _notifyOnDisplay, _notifyOnEntry, _notifyOnExit 依照順序放入陣列。
     *
     *   - 3. 依陣列位置給 2^0, 2^1, 2^2 值。
     *        - 因為代入的判斷參數只有 YES / NO 2 種狀態，故以 2 為基底。
     *        - 如代入的判斷參數有 0, 1, 2 這 3 種狀態，就要以 3 為基底，其它以此類推。
     *  
     *   - 4. 列舉陣列值，只要為 YES 就累加起來。
     *
     *   - 5. 最後依照累加的總值對應 KRBeaconNotifyModes 的位置即可。
     *
     */
    NSArray *_styles = @[[NSNumber numberWithBool:_notifyOnDisplay],
                         [NSNumber numberWithBool:_notifyOnEntry],
                         [NSNumber numberWithBool:_notifyOnExit]];
    //如代入的參數為 2 種判斷狀態，就以 2 為基底，如為 3 種判斷狀態，就代 3，其餘以此類推。
    int _binaryCode = 2;
    int _times      = 0;
    int _sum        = 0;
    for( NSNumber *_everyStyle in _styles )
    {
        if( YES == [_everyStyle boolValue] )
        {
            //sumOf( 2^0, 2^1 ... )
            _sum += (int)powf(_binaryCode, _times);
        }
        ++_times;
    }
    return (KRBeaconNotifyModes)_sum;
}

#pragma --mark Override Getters
-(KRBeaconPeripheral *)beaconPeripheral
{
    return [super beaconPeripheral];
}

-(CLLocationManager *)locationManager
{
    return [super locationManager];
}

-(DisplayRegionHandler)displayRegionHandler
{
    return [super displayRegionHandler];
}

-(FoundBeaconsHandler)foundBeaconsHandler
{
    return [super foundBeaconsHandler];
}

-(EnterRegionHandler)enterRegionHandler
{
    return [super enterRegionHandler];
}

-(ExitRegionHandler)exitRegionHandler
{
    return [super exitRegionHandler];
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
    NSLog(@"beacons 2 : %@", beacons);
    self.foundBeacons = beacons;
    if( self.foundBeaconsHandler )
    {
        self.foundBeaconsHandler(self.foundBeacons, region);
    }
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if( self.enterRegionHandler )
    {
        self.enterRegionHandler(manager, region);
    }
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if( self.exitRegionHandler )
    {
        self.exitRegionHandler(manager, region);
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if( self.oneDelegate )
    {
        if( [_oneDelegate respondsToSelector:@selector(krBeaconOne:didDetermineState:forRegion:)] )
        {
            [_oneDelegate krBeaconOne:self didDetermineState:state forRegion:region];
        }
    }
    
    if( self.displayRegionHandler )
    {
        self.displayRegionHandler(manager, region, state);
    }
}

@end