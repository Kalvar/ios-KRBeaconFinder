//
//  ViewController.m
//  KRBeaconFinder
//
//  Created by Kalvar on 2014/4/1.
//  Copyright (c) 2014年 Kalvar. All rights reserved.
//

#import "ViewController.h"
#import "KRBeaconFinder.h"

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
    
    self.beaconFinder        = [KRBeaconFinder sharedFinder];
    _beaconFinder.uuid       = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
    _beaconFinder.identifier = @"com.kalvar.ibeacons";
    [_beaconFinder setFoundBeaconsHandler:^(NSArray *foundBeacons, CLBeaconRegion *beaconRegion)
    {
        _weakSelf.detectedBeacons = foundBeacons;
        [_weakSelf.beaconTableView reloadData];
    }];
    [_beaconFinder setBleScanningEnumerator:^(CBPeripheral *peripheral, NSDictionary *advertisements, NSNumber *RSSI)
    {
        NSLog(@"I see an advertisement with identifer: %@, state: %d, name: %@, services: %@,  description: %@",
              [peripheral identifier],
              [peripheral state],
              [peripheral name],
              [peripheral services],
              [advertisements description]);
    }];
    
    //[_beaconFinder ranging];
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
    }
    else
    {
        [_beaconFinder stopRanging];
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
     *   - proximity 會顯示目前 Beacon 離 iPhone 多遠，單位是公尺( m )
     *   - rssi      會顯示目前的訊號強度，越近則越大，越遠則越小，範圍從 -43 ~ -94 以內為可信區域
     *
     */
    NSString *proximityString = @"";
    NSString *openWhat        = @"";
    switch (beacon.proximity) {
        case CLProximityNear:
            proximityString = @"Near";
            openWhat        = @"Google";
            break;
        case CLProximityImmediate:
            proximityString = @"Immediate";
            openWhat        = @"Yahoo";
            break;
        case CLProximityFar:
            proximityString = @"Far";
            openWhat        = @"StackOverflow";
            break;
        case CLProximityUnknown:
        default:
            proximityString = @"Unknown";
            openWhat        = @"Gone";
            break;
    }
    defaultCell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@ • %@ • %f • %li • %@",
                                        beacon.major.stringValue, beacon.minor.stringValue, proximityString, beacon.accuracy, (long)beacon.rssi, openWhat];
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
