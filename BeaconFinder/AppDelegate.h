//
//  AppDelegate.h
//  BeaconFinder
//
//  Created by Kalvar on 2013/11/30.
//  Copyright (c) 2013 - 2014年 Kalvar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KRBeaconFinder.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, KRBeaconFinderDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) KRBeaconFinder *beaconFinder;

@end
