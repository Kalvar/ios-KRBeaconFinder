//
//  ViewController.h
//  KRBeaconFinder
//
//  Created by Kalvar on 2014/4/1.
//  Copyright (c) 2014年 Kalvar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KRBeaconFinder;

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UISwitch *advertisingSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *rangingSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *bleScanningSwitch;
@property (nonatomic, weak) IBOutlet UITableView *beaconTableView;

@property (nonatomic, strong) NSArray *detectedBeacons;

@property (nonatomic, strong) KRBeaconFinder *beaconFinder;

@end
