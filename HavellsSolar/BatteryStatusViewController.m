//
//  BatteryStatusViewController.m
//  HavellsSolar
//
//  Created by Sivakumar  K R on 09/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import "BatteryStatusViewController.h"
#import "BluetoothDiscovery.h"
#import "SolarCommands.h"

@interface BatteryStatusViewController ()<BluetoothDiscoveryDelegate>
@property(strong,atomic) NSMutableArray * barButtons;

@end

@implementation BatteryStatusViewController

- (void) loadUI
{
    if(self.loadingActivityView == nil){
        self.loadingActivityView = [[UIActivityIndicatorView alloc] initWithFrame:self.refreshBarButton.customView.frame];
        self.activityBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.loadingActivityView];
        self.activityBarButton.enabled = NO;
    }
    _barButtons = [[NSMutableArray alloc] initWithArray:self.navigationItem.rightBarButtonItems];
    
    _chargingSwitch.enabled = NO;
    
    self.batteryCapacityLabel.text = @"00:00";
}
- (void) loadDelegate
{
    [[BluetoothDiscovery sharedInstance] setDiscoveryDelegate:self];
    [[SolarCommands sharedInstance] sendReadRfrsh];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUI];
    
    
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [self loadDelegate];
    if(_batteryVoltage!=nil && (![_batteryVoltage isEqualToString:@""]))
       self.batteryVoltageLabel.text = _batteryVoltage;
    if(_batteryCurrent!=nil && (![_batteryCurrent isEqualToString:@""]))
        self.batteryCurrentLabel.text = _batteryCurrent;
    if(_batteryStatus!=nil && (![_batteryStatus isEqualToString:@""]))
        self.batteryStatusLabel.text = _batteryCurrent;
    if(_panelI && ([_panelI doubleValue] > 0.0)) {
        _chargingStatusImageView.image = [UIImage imageNamed:@"newcharging.png"];
        [_chargingSwitch setOn:YES];
        _chargingStatusLabel.text = @"CHARGING";
    }else{
        _chargingStatusImageView.image = [UIImage imageNamed:@"newdischarging.png"];
        [_chargingSwitch setOn:NO];
        _chargingStatusLabel.text = @"DISCHARGING";
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma  mark User Actions
- (IBAction)touchUpRefresh:(id)sender {
    [[SolarCommands sharedInstance] sendReadRfrsh];
}

- (void) sendCommand:(NSString *) cmd
{
    //Set Activity View
    BOOL flag = YES;
    NSNumber *flagValue = [NSNumber numberWithBool:flag];
    [self flipRightBarButton:flagValue];
    
    //Send Command
    [[BluetoothDiscovery sharedInstance] writeCommand:cmd];
    
    
    //Set Refresh Button after 7 seconds
    flag = NO;
    flagValue = [NSNumber numberWithBool:flag];
    [self performSelector:@selector(flipRightBarButton:) withObject:flagValue afterDelay:7 ];
    
}
- (void)flipRightBarButton:(NSNumber *) flag
{
    BOOL val = [flag boolValue];
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:self.navigationItem.rightBarButtonItems];
    if (val){
        
        //Replace refresh button with loading spinner
        if([items containsObject:self.refreshBarButton]){
            [items replaceObjectAtIndex:[items indexOfObject:self.refreshBarButton]
                             withObject:self.activityBarButton];
            
            //Animate the loading spinner
            [self.loadingActivityView startAnimating];
        }
        
    }
    else{
        if([items containsObject:self.activityBarButton]){
            [items replaceObjectAtIndex:[items indexOfObject:self.activityBarButton]
                             withObject:self.refreshBarButton];
            [self.loadingActivityView stopAnimating];
        }
    }
    
    self.navigationItem.rightBarButtonItems = items;
}

#pragma mark Bluetooth Delegate
- (void)valueChanged:(NSString *)string
{
    
    if([string containsString:@"Bv"]){
        //1Bv......1 --> Taking only dots
        NSString *val = [string substringWithRange:NSMakeRange(3, [string length]-4)];
        self.batteryVoltageLabel.text = [NSString stringWithFormat:@"Voltage=%04.1fV",[val doubleValue]];
            
            //Setting the battery percent
            //Formula: ((V * 10) - 110))*2.5
            float temp = [val floatValue];
            temp = ((temp * 10) - 110)*2.5;
            
        if(temp>=100)
            self.batteryStatusLabel.text = [NSString stringWithFormat:@"%d%%",100];
        else
            self.batteryStatusLabel.text = [NSString stringWithFormat:@"%d%%",(int)temp];
    }else if([string containsString:@"Bi"]){
        //1Bi......1 --> Taking only dots
        NSString *val = [string substringWithRange:NSMakeRange(3, [string length]-4)];
        self.batteryCurrentLabel.text = [NSString stringWithFormat:@"Current=%04.1fA",[val doubleValue]];
    }else if([string containsString:@"Pi"]){
        
        //1Pi......1 --> Taking only dots
        NSString *val = [string substringWithRange:NSMakeRange(3, [string length]-4)];
        self.panelI = [NSString stringWithFormat:@"%04.1f",[val doubleValue]];
        
        
        if(_panelI && ([_panelI doubleValue] > 0.0)) {
            _chargingStatusImageView.image = [UIImage imageNamed:@"newcharging.png"];
            [_chargingSwitch setOn:YES];
            _chargingStatusLabel.text = @"CHARGING";
        }else{
            _chargingStatusImageView.image = [UIImage imageNamed:@"newdischarging.png"];
            [_chargingSwitch setOn:NO];
            _chargingStatusLabel.text = @"DISCHARGING";
        }
    }else if([string containsString:@"BU"]){
        _batteryCapacityLabel.text = [string substringWithRange:NSMakeRange(3, [string length]-4)];
    }
}
- (void)stateChanged:(NSString *)string
{
    if([string containsString:@"PoweredOff"]){
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Bluetooth State" message:@"Please turn on bluetooth" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alerView show];
    }
}


- (void) connectionStateChanged:(NSString *) string{
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Info" message:string delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alerView show];
}

- (void)isScanning:(BOOL)flag
{
    
}

@end
