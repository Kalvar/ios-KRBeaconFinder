//
//  KRBeaconFinder.h
//  KRBeaconFinder V1.5.1
//
//  Created by Kalvar on 2013/07/01.
//  Copyright (c) 2013 - 2015年 Kalvar. All rights reserved.
//

#import "KRBeaconFinder.h"

@protocol KRBeaconOneDelegate;

@interface KRBeaconOne : KRBeaconFinder
{
    
}

@property (nonatomic, strong) id<KRBeaconOneDelegate> oneDelegate;

//Your Apple Certificated Beacon ID
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, assign) NSInteger major;
@property (nonatomic, assign) NSInteger minor;

@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

@property (nonatomic, assign) BOOL notifyOnDisplay;
@property (nonatomic, assign) BOOL notifyOnEntry;
@property (nonatomic, assign) BOOL notifyOnExit;
@property (nonatomic, assign) KRBeaconNotifyModes notifyMode;

#pragma --mark Public Methods
+(instancetype)sharedFinder;
-(instancetype)init;

#pragma --mark Override Add Region Methods
-(void)addRegionWithUuid:(NSString *)_beaconUuid identifier:(NSString *)_beaconIdentifier major:(NSInteger)_beaconMajor minor:(NSInteger)_beaconMinor;

#pragma --mark Override Ranging Methods
-(void)rangingWithBeaconsFounder:(FoundBeaconsHandler)_founder;
-(void)ranging;
-(void)stopRanging;

#pragma --mark Monitoring Methods
-(void)monitoringWithDisplayHandler:(DisplayRegionHandler)_handler;
-(void)monitoring;
-(void)stopMonitoring;
-(void)awakeDisplayWithFoundCompletion:(DisplayRegionHandler)_completion;
-(void)awakeDisplay;

@end

@protocol KRBeaconOneDelegate <NSObject>

@optional
-(void)krBeaconOne:(KRBeaconOne *)beaconFinder didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region;

@end
