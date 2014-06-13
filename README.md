## About

KRBeaconFinder is a easy finding and scanning the nearby beacons, you can lazy using CoreLocation ( GPS ) to monitor beacon regions or use CoreBluetooth ( BLE ) to scan the beacons. It also can simulate beacon adversting from peripheral adversting.

More Information see the souce code or email me.

## How To Get Started

1. If you just wanna watch one ibeacon device, you can direct using KRBeaconFinder.

``` objective-c
#import "KRBeaconFinder.h"

@interface ViewController ()<KRBeaconFinderDelegate>

@end

- (void)viewDidLoad
{
    [super viewDidLoad];
 	   
    __weak typeof(self) _weakSelf = self;
    
    self.beaconFinder        = [KRBeaconFinder sharedFinder];
    _beaconFinder.uuid       = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
    _beaconFinder.identifier = @"com.kalvar.ibeacons";
    _beaconFinder.meDelegate = self;

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

}

#pragma --mark Switch Actions
-(void)simulateBeaconAdversting
{
    if ( self.isSimulateBeaconAdversting )
    {
        [_beaconFinder bleAdversting];
    }
    else
    {
        [_beaconFinder bleStopAdversting];
    }
}

-(void)monitorBeaconRegions
{
    if ( self.isMonitoringBeaconRegions )
    {
        [_beaconFinder ranging];
    }
    else
    {
        [_beaconFinder stopRanging];
    }
}

-(void)bleScanBeacons
{
    if ( self.isBleScanBeacons )
    {
        [_beaconFinder bleScan];
    }
    else
    {
        [_beaconFinder bleStopScan];
    }
}

#pragma --mark KRBeaconFinderDelegate
-(void)krBeaconFinder:(KRBeaconFinder *)beaconFinder didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if( [UIApplication sharedApplication].applicationState != UIApplicationStateActive )
    {
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
```

2. If you wanna watch more ibeacons, you can use KRBeacons.

``` objective-c
#import "KRBeacons.h"

@interface ViewController ()<KRBeaconsDelegate>

@end

- (void)viewDidLoad
{
    [super viewDidLoad];
       
    __weak typeof(self) _weakSelf = self;
    
    self.beaconFinder      = [KRBeacons sharedInstance];
    _beaconFinder.delegate = self;
    [_beaconFinder addRegionWithUuid:@"A9407F30-F5F8-466E-AFF9-25556B57FE6D" identifier:@"com.kalvar.ibeacons1"];
    [_beaconFinder addRegionWithUuid:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D" identifier:@"com.kalvar.ibeacons2"];
    [_beaconFinder addRegionWithUuid:@"C9407F30-F5F8-466E-AFF9-25556B57FE6D" identifier:@"com.kalvar.ibeacons3"];

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

}

#pragma --mark Switch Actions
-(void)simulateBeaconAdversting
{
    if ( self.isSimulateBeaconAdversting )
    {
        [_beaconFinder bleAdversting];
    }
    else
    {
        [_beaconFinder bleStopAdversting];
    }
}

-(void)monitorBeaconRegions
{
    if ( self.isMonitoringBeaconRegions )
    {
        [_beaconFinder ranging];
    }
    else
    {
        [_beaconFinder stopRanging];
    }
}

-(void)bleScanBeacons
{
    if ( self.isBleScanBeacons )
    {
        [_beaconFinder bleScan];
    }
    else
    {
        [_beaconFinder bleStopScan];
    }
}

#pragma --mark KRBeaconsDelegate
-(void)krBeacons:(KRBeacons *)krBeacons didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if( [UIApplication sharedApplication].applicationState != UIApplicationStateActive )
    {
        if(state == CLRegionStateInside)
        {
            [krBeacons fireLocalNotificationWithMessage:@"You're inside the beacon delegate"];
        }
        else if(state == CLRegionStateOutside)
        {
            [krBeacons fireLocalNotificationWithMessage:@"You're outside the beacon delegate"];
        }
        else
        {
            return;
        }
    }
}

//... More Information live in source code :)

```

## Version

V1.2.

## License

MIT.
