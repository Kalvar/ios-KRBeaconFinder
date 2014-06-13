//
//  KRBeaconFinder.h
//  KRBeaconFinder V1.2
//
//  Created by Kalvar on 2013/11/30.
//  Copyright (c) 2013 - 2014年 Kalvar. All rights reserved.
//

#import "KRBeacons.h"

@protocol KRBeaconFinderDelegate;

@interface KRBeaconFinder : KRBeacons
{
    
}

@property (nonatomic, strong) id<KRBeaconFinderDelegate> meDelegate;

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
-(void)ranging;
-(void)stopRanging;

#pragma --mark Monitoring Methods
-(void)monitoring;
-(void)stopMonitoring;
-(void)awakeDisplayWithRequestCompletion:(DisplayRegionHandler)_completion;
-(void)awakeDisplay;

@end

@protocol KRBeaconFinderDelegate <NSObject>

@optional
-(void)krBeaconFinder:(KRBeaconFinder *)beaconFinder didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region;

@end
