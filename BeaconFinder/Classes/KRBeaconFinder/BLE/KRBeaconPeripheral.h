//
//  KRBeaconPeripheralManager.h
//  KRBeaconFinder V1.4
//
//  Created by Kalvar on 2013/07/01.
//  Copyright (c) 2013 - 2014年 Kalvar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBPeripheralManager;
@class CLBeaconRegion;

@interface KRBeaconPeripheral : NSObject

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

+(instancetype)sharedPeripheral;
-(instancetype)init;
-(void)advertising;
-(void)stopAdvertising;

@end
