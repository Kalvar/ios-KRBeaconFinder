//
//  KRBeaconPeripheralManager.h
//  KRBeaconFinder V1.2
//
//  Created by Kalvar on 2013/11/30.
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
