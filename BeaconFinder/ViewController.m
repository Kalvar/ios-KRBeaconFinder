//
//  ViewController.m
//  KRBeaconFinder
//
//  Created by Kalvar on 2013/07/01.
//  Copyright (c) 2013 - 2014年 Kalvar. All rights reserved.
//

#import "ViewController.h"
#import "KRBeaconOne.h"
#import "AppDelegate.h"

@interface ViewController ()


@end

@implementation ViewController

@synthesize advertisingSwitch = _advertisingSwitch;
@synthesize rangingSwitch     = _rangingSwitch;
@synthesize bleScanningSwitch = _bleScanningSwitch;
@synthesize beaconTableView   = _beaconTableView;

@synthesize beaconFinder      = _beaconFinder;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.advertisingSwitch addTarget:self
                               action:@selector(changeAdvertisingState:)
                     forControlEvents:UIControlEventValueChanged];
    
    [self.rangingSwitch addTarget:self
                           action:@selector(changeRangingState:)
                 forControlEvents:UIControlEventValueChanged];
    
    [self.bleScanningSwitch addTarget:self
                               action:@selector(changeScanningState:)
                     forControlEvents:UIControlEventValueChanged];
    
    __weak typeof(self) _weakSelf = self;
    
    //Let's get start in Beacons coding ...
    
    //建立要讓 App 發廣播的 BeaconRegion, 這能讓 iPhone 變成客製化的 iBeacon
    //Build the beacon region of advertising within use app which can be customized iBeacon.
    /*
    self.beaconFinder          = [KRBeaconFinder sharedFinder];
    [_beaconFinder createAdvertisingRegionWithUuid:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
                                        identifier:@"com.kalvar.ibeacons"
                                             major:55000
                                             minor:65000];
    //*/
    
    //Same as [(AppDelegate *)[UIApplication sharedApplication].delegate beaconFinder];
    self.beaconFinder          = [KRBeaconOne sharedFinder];
    
    //_beaconFinder.uuid       = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
    //_beaconFinder.identifier = @"com.kalvar.ibeacons";
    
    __weak typeof(_beaconFinder) _weakBeaconFinder = _beaconFinder;
    
    [_beaconFinder setFoundBeaconsHandler:^(NSArray *foundBeacons, CLBeaconRegion *beaconRegion)
    {
        _weakSelf.detectedBeacons = foundBeacons;
        [_weakSelf.beaconTableView reloadData];
    }];
    
    [_beaconFinder setBleScanningEnumerator:^(CBPeripheral *peripheral, NSDictionary *advertisements, NSNumber *RSSI)
    {
        NSLog(@"The advertisement with identifer: %@, state: %d, name: %@, services: %@,  description: %@",
              [peripheral identifier],
              [peripheral state],
              [peripheral name],
              [peripheral services],
              [advertisements description]);
    }];
    
    [_beaconFinder setEnterRegionHandler:^(CLLocationManager *manager, CLRegion *region)
    {
        [_weakBeaconFinder fireLocalNotificationWithMessage:@"Enter region notification" userInfo:@{@"key" : @"doShareToPeople"}];
    }];
    
    [_beaconFinder setExitRegionHandler:^(CLLocationManager *manager, CLRegion *region)
    {
        [_weakBeaconFinder fireLocalNotificationWithMessage:@"Exit region notification"];
    }];
    
    /*
    //It works without write in AppDelegate, but you must be uniform integration the processing and coding-style in one scope.
    [_beaconFinder setDisplayRegionHandler:^(CLLocationManager *manager, CLRegion *region, CLRegionState state)
    {
        if(state == CLRegionStateInside)
        {
            [_weakBeaconFinder fireLocalNotificationWithMessage:@"You're inside the beacon region 2"];
        }
        else if(state == CLRegionStateOutside)
        {
            [_weakBeaconFinder fireLocalNotificationWithMessage:@"You're outside the beacon region 2"];
        }
        else
        {
            return;
        }
    }];
    */
    
    /*
    //It works for watching more iBeacons.
    [[KRBeacons sharedInstance] addRegionWithUuid:@"A9407F30-F5F8-466E-AFF9-25556B57FE6D" identifier:@"com.kalvar.ibeacons1"];
    [[KRBeacons sharedInstance] addRegionWithUuid:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D" identifier:@"com.kalvar.ibeacons2"];
    [[KRBeacons sharedInstance] addRegionWithUuid:@"C9407F30-F5F8-466E-AFF9-25556B57FE6D" identifier:@"com.kalvar.ibeacons3"];
    [[KRBeacons sharedInstance] ranging];
    [[KRBeacons sharedInstance] monitoring];
     */
    
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma --mark Switch Actions
-(void)changeAdvertisingState:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    if (theSwitch.on)
    {
        [_beaconFinder bleAdversting];
    }
    else
    {
        [_beaconFinder bleStopAdversting];
    }
}

-(void)changeRangingState:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    if (theSwitch.on)
    {
        [_beaconFinder ranging];
        //[_beaconFinder monitoring];
    }
    else
    {
        [_beaconFinder stopRanging];
        //[_beaconFinder stopMonitoring];
    }
}

-(void)changeScanningState:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    if (theSwitch.on)
    {
        [_beaconFinder bleScan];
    }
    else
    {
        [_beaconFinder bleStopScan];
    }
}

-(void)removeRegionSample
{
    //It'll remove all beacons from matched the UUID and Identifier.
    [_beaconFinder removeRegionWithUuid:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D" identifier:@"com.kalvar.ibeacons"];
    
    //It'll remove all beacons from matched the UUID, Identifier and Major.
    [_beaconFinder removeRegionWithUuid:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D" identifier:@"com.kalvar.ibeacons" major:2540];
    
    //It'll remove all beacons from matched the UUID, Identifier, Major and Minor.
    [_beaconFinder removeRegionWithUuid:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D" identifier:@"com.kalvar.ibeacons" major:2540 minor:1028];
    
    //It'll remove the specified region.
    CLBeaconRegion *_beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D" ] identifier:@"com.kalvar.ibeacons"];
    [_beaconFinder removeRegion:_beaconRegion];
}

#pragma --mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.detectedBeacons.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Detected beacons";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLBeacon *beacon = self.detectedBeacons[indexPath.row];
    
    UITableViewCell *defaultCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                          reuseIdentifier:@"BeaconCells"];
    
    defaultCell.textLabel.text = beacon.proximityUUID.UUIDString;
    
    /*
     * @ Noted
     *   - 收到的 Beacon 訊息
     *     CLBeacon (uuid:<__NSConcreteUUID 0x146c6c80> B9407F30-F5F8-466E-AFF9-25556B57FE6D,
     *               major:18527,
     *               minor:23618,
     *               proximity:1 +/- 0.07m,
     *               rssi:-53)
     *
     *   - uuid      是 Apple Certificated Beacon ID，不同於 Device UUID
     *   - major     是 該 Beacons 群組 ID，當接收到 uuid 判斷為可以作動的 Beacons 後，就依照 major 來判斷是要做什麼類型的事情
     *   - minor     是 該 Beacons 群組底下，每一顆 Beacon 可以做什麼事情的判斷 ID
     *   - accuracy  會顯示目前 Beacon 離 iPhone 多遠，單位是公尺( meter ), not proximity
     *   - rssi      會顯示目前的訊號強度，越近則越大，越遠則越小，範圍從 -43 ~ -94 以內為可信區域
     *
     */
    NSString *proximityString = @"";
    switch (beacon.proximity) {
        case CLProximityImmediate:
            //~ 50 cm
            proximityString = @"Immediate";
            break;
        case CLProximityNear:
            //~ 2 m
            proximityString = @"Near";
            break;
        case CLProximityFar:
            //~ 30 m
            proximityString = @"Far";
            break;
        case CLProximityUnknown:
        default:
            proximityString = @"Unknown";
            break;
    }
    defaultCell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@ • %@ • %f • %li • %.2fm",
                                        beacon.major.stringValue, beacon.minor.stringValue, proximityString, beacon.accuracy, (long)beacon.rssi, beacon.accuracy];
    defaultCell.detailTextLabel.textColor = [UIColor grayColor];
    
    return defaultCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CLBeacon *beacon = self.detectedBeacons[indexPath.row];
    switch ([beacon.major integerValue])
    {
        //Something wanna do with major.
        case 18527:
        {
            //... Do Something.
        }
            break;
        default:
            break;
    }
}

@end
