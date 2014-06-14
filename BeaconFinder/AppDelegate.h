//
//  AppDelegate.h
//  KRBeaconFinder
//
//  Created by Kalvar on 2013/07/01.
//  Copyright (c) 2013 - 2014年 Kalvar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KRBeaconOne.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, KRBeaconOneDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) KRBeaconOne *beaconFinder;

@end
