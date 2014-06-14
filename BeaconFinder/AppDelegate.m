//
//  AppDelegate.m
//  KRBeaconFinder
//
//  Created by Kalvar on 2013/07/01.
//  Copyright (c) 2013 - 2014年 Kalvar. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize locationManager = _locationManager;
@synthesize beaconFinder    = _beaconFinder;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*
     * @ 一定要在 AppDelegate 裡實行 Monitoring 才能正確的監控「背景移除 App 後，還能在鎖屏畫面下呈現 iBeacon 通知」的功能。
     */
    _beaconFinder             = [KRBeaconOne sharedFinder];
    _beaconFinder.oneDelegate = self;
    _beaconFinder.uuid        = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
    _beaconFinder.identifier  = @"com.kalvar.ibeacons";
    [_beaconFinder awakeDisplay];
    
    /*
    //原先啟動 App 被背景移除，且 iPhone 被鎖屏的監控方法
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    NSUUID *estimoteUUID = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:estimoteUUID
                                                                identifier:@"Estimote Range"];
    
    // launch app when display is turned on and inside region
    region.notifyEntryStateOnDisplay = YES;
    
    //Device 支援監控 BeaconRegion 的話
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]])
    {
        //重新啟動監控 BeaconRegion
        [_locationManager startMonitoringForRegion:region];
        
        //請求啟動 locationManager:didDetermineState:forRegion: 委派方法
        [_locationManager requestStateForRegion:region];
    }
    else
    {
        NSLog(@"This device does not support monitoring beacon regions");
    }
    */
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                [app endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                [app endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

/*
 * @ 收到本地通知時
 */
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You received"
                                                    message:notification.alertBody
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma --mark KRBeaconFinderDelegate
-(void)krBeaconOne:(KRBeaconOne *)beaconFinder didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSLog(@"state : %i", [UIApplication sharedApplication].applicationState);
    
    /*
     * @ [UIApplication sharedApplication].applicationState
     *
     *   UIApplicationStateActive     , 0 : App 前台活動中
     *   UIApplicationStateInactive   , 1 : App 在後台被掛起無法運行，剛 Launch 進 App 時，也是這狀態，要注意
     *   UIApplicationStateBackground , 2 : App 在後台運行或僅在後台未被掛起
     *
     * @ 最一開始出現系統的「xxx 想要使用您目前的位置」AlertView 時，整支 App 會變成 UIApplicationStateInactive 不活躍模式，
     *   之後第 2 次再進 App，且為第 1 次執行這裡，也會是 UIApplicationStateActive 前台活動中的模式。
     *
     */
    if( [UIApplication sharedApplication].applicationState != UIApplicationStateActive )
    {
        //如果指定監控的 BeaconRegion 裡有設定 Major / Minor 的話，這裡就能取得值，否則無值。
        //CLBeaconRegion *_beaconRegion = (CLBeaconRegion *)region;
        //NSLog(@"_beaconRegion : %i, %i", [_beaconRegion.major integerValue], [_beaconRegion.minor integerValue]);
        
        //無值
        //NSNumber *_major = beaconFinder.beaconRegion.major;
        //NSNumber *_minor = beaconFinder.beaconRegion.minor;
        
        if(state == CLRegionStateInside)
        {
            [beaconFinder fireLocalNotificationWithMessage:@"You're inside the beacon delegate"];
        }
        else if(state == CLRegionStateOutside)
        {
            [beaconFinder fireLocalNotificationWithMessage:@"You're outside the beacon delegate"];
        }
        else
        {
            return;
        }
    }
}


@end
