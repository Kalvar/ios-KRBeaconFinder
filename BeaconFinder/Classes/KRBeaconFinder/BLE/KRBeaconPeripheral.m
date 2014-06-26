//
//  KRBeaconPeripheralManager.m
//  KRBeaconFinder V1.5
//
//  Created by Kalvar on 2013/07/01.
//  Copyright (c) 2013 - 2014年 Kalvar. All rights reserved.
//

#import "KRBeaconPeripheral.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@interface KRBeaconPeripheral ()<CBPeripheralManagerDelegate>

@end

@implementation KRBeaconPeripheral (fixPeripheralData)

-(NSDictionary *)_buildBeaconPeripheralData
{
    time_t t;
    srand((unsigned) time(&t));
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:self.beaconRegion.proximityUUID
                                                                     major:rand()
                                                                     minor:rand()
                                                                identifier:self.beaconRegion.identifier];
    return [region peripheralDataWithMeasuredPower:nil];
}

@end

@implementation KRBeaconPeripheral

@synthesize peripheralManager = _peripheralManager;
@synthesize beaconRegion      = _beaconRegion;

+(instancetype)sharedPeripheral
{
    static dispatch_once_t pred;
    static KRBeaconPeripheral *_object = nil;
    dispatch_once(&pred, ^{
        _object = [[KRBeaconPeripheral alloc] init];
    });
    return _object;
}

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        
    }
    return self;
}

-(void)advertising
{
    if( !_beaconRegion )
    {
        return;
    }
    
    if ( !_peripheralManager )
    {
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    }
    
    if ( _peripheralManager.state != CBPeripheralManagerStatePoweredOn )
    {
        return;
    }
    
    [_peripheralManager startAdvertising:[self _buildBeaconPeripheralData]];
}

-(void)stopAdvertising
{
    [_peripheralManager stopAdvertising];
}

#pragma mark - Beacon advertising delegate methods
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheralManager error:(NSError *)error
{
    if (error)
    {
        return;
    }
    
    if (peripheralManager.isAdvertising)
    {
        //...
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager
{
    if ( peripheralManager.state != CBPeripheralManagerStatePoweredOn )
    {
        return;
    }
    
    [self advertising];
}


@end
