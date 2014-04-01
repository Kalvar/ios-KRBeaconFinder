//
//  KRBeaconPeripheralManager.h
//  KRBeaconFinder V1.0
//
//  Created by Kalvar on 2014/4/1.
//  Copyright (c) 2014年 Kalvar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBPeripheralManager;
@class CLBeaconRegion;

@interface KRBeaconPeripheralManager : NSObject

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

+(instancetype)sharedManager;
-(void)advertising;
-(void)stopAdvertising;

@end
