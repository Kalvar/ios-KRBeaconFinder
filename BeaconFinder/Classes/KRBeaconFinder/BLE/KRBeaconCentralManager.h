//
//  KRBeaconCentralManager.h
//  KRBeaconFinder V1.0
//
//  Created by Kalvar on 2014/4/1.
//  Copyright (c) 2014年 Kalvar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBCentralManager;
@class CBPeripheral;

typedef void(^ScanningEnumerator) (CBPeripheral *peripheral, NSDictionary *advertisements, NSNumber *RSSI);

@interface KRBeaconCentralManager : NSObject

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic, copy) ScanningEnumerator scanningEnumerator;

#pragma --mark Public Methods
+(instancetype)sharedManager;
-(instancetype)init;
-(void)scanWithEnumerator:(ScanningEnumerator)_enumerator;
-(void)scan;
-(void)stopScan;

#pragma --mark Setters
-(void)setScanningEnumerator:(ScanningEnumerator)_theScanningEnumerator;




@end
