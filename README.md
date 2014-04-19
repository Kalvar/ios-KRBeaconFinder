## About

KRBeaconFinder is a easy finding and scanning the nearby beacons, you can lazy using CoreLocation ( GPS ) to monitor beacon regions or use CoreBluetooth ( BLE ) to scan the beacons. It also can simulate beacon adversting from peripheral adversting.

More Information see the souce code, please.

## How To Get Started

``` objective-c
- (void)viewDidLoad
{
    [super viewDidLoad];
 	   
    __weak typeof(self) _weakSelf = self;
    
    self.beaconFinder        = [KRBeaconFinder sharedFinder];
    _beaconFinder.uuid       = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
    _beaconFinder.identifier = @"com.kalvar.ibeacons";
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

//... More Information live in source code :)

```

## Version

V1.1.

## License

MIT.
