//
//  KRBeaconCentralManager.m
//  KRBeaconFinder V1.0
//
//  Created by Kalvar on 2014/4/1.
//  Copyright (c) 2014年 Kalvar. All rights reserved.
//

#import "KRBeaconCentralManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface KRBeaconCentralManager()<CBCentralManagerDelegate>

@end

@implementation KRBeaconCentralManager (fixScanning)



@end

@implementation KRBeaconCentralManager

@synthesize centralManager     = _centralManager;
@synthesize peripheral         = _peripheral;
@synthesize scanningEnumerator = _scanningEnumerator;

#pragma --mark Public Methods
+(instancetype)sharedManager
{
    static dispatch_once_t pred;
    static KRBeaconCentralManager *_object = nil;
    dispatch_once(&pred, ^{
        _object = [[KRBeaconCentralManager alloc] init];
    });
    return _object;
}

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        dispatch_queue_t _centralQueue = dispatch_queue_create("CentralManagerQueue", DISPATCH_QUEUE_SERIAL);
        _centralManager     = [[CBCentralManager alloc] initWithDelegate:self queue:_centralQueue];
        _peripheral         = nil;
        _scanningEnumerator = nil;
    }
    return self;
}

-(void)scanWithEnumerator:(ScanningEnumerator)_enumerator
{
    _scanningEnumerator = _enumerator;
    [self scan];
}

-(void)scan
{
    [self stopScan];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    [self.centralManager scanForPeripheralsWithServices:nil options:options];
}

-(void)stopScan
{
    [_centralManager stopScan];
}

#pragma --mark Setters
-(void)setScanningEnumerator:(ScanningEnumerator)_theScanningEnumerator
{
    _scanningEnumerator = _theScanningEnumerator;
}

#pragma --mark CentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStatePoweredOn:
        {
            //Kalvar : 別把 Scan 寫在這裡, 直接使用 Scan 的函式即可
            break;
        }
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if( self.scanningEnumerator )
    {
        _scanningEnumerator(peripheral, advertisementData, RSSI);
    }
    
    //Beacons 是不能被連線的，所以就不用做連線
    
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //...
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSArray *)serviceUuids
{
    //NSLog(@"discovered a peripheral's services: %@", serviceUuids);
}

@end
