//
//  KRBeaconCentralManager.h
//  KRBeaconFinder V1.5
//
//  Created by Kalvar on 2013/07/01.
//  Copyright (c) 2013 - 2014年 Kalvar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBCentralManager;
@class CBPeripheral;

typedef void(^ScanningEnumerator) (CBPeripheral *peripheral, NSDictionary *advertisements, NSNumber *RSSI);

@interface KRBeaconCentral : NSObject

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic, copy) ScanningEnumerator scanningEnumerator;

#pragma --mark Public Methods
+(instancetype)sharedCentral;
-(instancetype)init;
-(void)scanWithEnumerator:(ScanningEnumerator)_enumerator;
-(void)scan;
-(void)stopScan;

#pragma --mark Setters
-(void)setScanningEnumerator:(ScanningEnumerator)_theScanningEnumerator;

@end
