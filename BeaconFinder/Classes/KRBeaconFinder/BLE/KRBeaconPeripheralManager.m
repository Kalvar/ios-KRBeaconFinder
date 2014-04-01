//
//  KRBeaconPeripheralManager.m
//  KRBeaconFinder V1.0
//
//  Created by Kalvar on 2014/4/1.
//  Copyright (c) 2014年 Kalvar. All rights reserved.
//

#import "KRBeaconPeripheralManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@interface KRBeaconPeripheralManager ()<CBPeripheralManagerDelegate>

@end

@implementation KRBeaconPeripheralManager

@synthesize peripheralManager = _peripheralManager;
@synthesize beaconRegion      = _beaconRegion;

+(instancetype)sharedManager
{
    static dispatch_once_t pred;
    static KRBeaconPeripheralManager *_object = nil;
    dispatch_once(&pred, ^{
        _object = [[KRBeaconPeripheralManager alloc] init];
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
    
    time_t t;
    srand((unsigned) time(&t));
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:_beaconRegion.proximityUUID
                                                                     major:rand()
                                                                     minor:rand()
                                                                identifier:_beaconRegion.identifier];
    NSDictionary *beaconPeripheralData = [region peripheralDataWithMeasuredPower:nil];
    [_peripheralManager startAdvertising:beaconPeripheralData];
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
