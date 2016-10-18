//
//  DashboardViewController.m
//  HavellsSolar
//
//  Created by Sivakumar  K R on 03/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import "DashboardViewController.h"
#import "BluetoothDiscovery.h"
#import "BatteryStatusViewController.h"
#import "SolarPanelStatusViewController.h"
#import "LampControlViewController.h"
#import "SolarCommands.h"

@interface DashboardViewController ()<BluetoothDiscoveryDelegate>

@property(strong,atomic) NSMutableArray * barButtons;
@property(strong,atomic) NSString * panelI;

//Light state ON or OFF
@property(strong,atomic) NSString *flag;
@end

@implementation DashboardViewController
UIView *refreshFrame;
- (void) loadUI{
    self.tempRefreshBarButton = self.activityBarButton;
    self.batteryVoltageLabel.numberOfLines = 1;
    self.solarVoltageLabel.numberOfLines = 1;
    self.lampVoltageLabel.numberOfLines = 1;
    self.batteryVoltageLabel.adjustsFontSizeToFitWidth = YES;
    self.solarVoltageLabel.adjustsFontSizeToFitWidth = YES;
    self.lampVoltageLabel.adjustsFontSizeToFitWidth = YES;
    
    refreshFrame = self.refreshBarButton.customView;
    if(self.loadingActivityView == nil){
        self.loadingActivityView = [[UIActivityIndicatorView alloc] initWithFrame:self.refreshBarButton.customView.frame];
        self.activityBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.loadingActivityView];
        self.activityBarButton.enabled = NO;
    }
    _barButtons = [[NSMutableArray alloc] initWithArray:self.navigationItem.rightBarButtonItems];
}

- (void) loadDelegate
{
    [[BluetoothDiscovery sharedInstance] setDiscoveryDelegate:self];
    [[SolarCommands sharedInstance] sendReadRfrsh];
    self.flag = @"ON";
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUI];
        
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadDelegate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma  mark User Actions
- (IBAction)touchUpRefresh:(id)sender {
    
    [[SolarCommands sharedInstance] sendReadRfrsh];

}

- (IBAction)touchUpDisconnect:(id)sender {
    [[SolarCommands sharedInstance] sendUnpair];

//    sleep(1);
    [[BluetoothDiscovery sharedInstance] disconnectPeripheral:[[BluetoothDiscovery sharedInstance] getConnectedPeripheral]];
    [self performSegueWithIdentifier:@"searchlamps" sender:self];
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
    BOOL flag1 = NO;
    NSNumber *flag1Value = [NSNumber numberWithBool:flag1];
    [self performSelector:@selector(flipRightBarButton:) withObject:flag1Value afterDelay:7];

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




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"batterystatus"])
    {
        BatteryStatusViewController *viewController =segue.destinationViewController;
        
        viewController.batteryVoltage = [NSString stringWithFormat:@"Voltage=%@",self.batteryVoltageLabel.text];;
        viewController.batteryCurrent = [NSString stringWithFormat:@"Current=%@",self.batteryCurrentLabel.text];
        viewController.batteryStatus = self.batteryPercentageLabel.text;
        if(self.panelI) viewController.panelI = self.panelI;
        
        
    }else if([segue.identifier isEqualToString:@"solarpanelstatus"]){
        SolarPanelStatusViewController *viewController =segue.destinationViewController;
        viewController.solarVoltage = [NSString stringWithFormat:@"Voltage=%@",self.solarVoltageLabel.text];;
        viewController.solarCurrent = [NSString stringWithFormat:@"Current=%@",self.batteryCurrentLabel.text];
        
    }
        
}


- (IBAction)unwindToDashboard:(UIStoryboardSegue *)unwindSegue
{
    NSLog(@"Coming from GREEN!");
}

- (IBAction)performBatteryStatusSegue:(id)sender {
    [self performSegueWithIdentifier:@"batterystatus" sender:self];
}

- (IBAction)performSolarPanelSegue:(id)sender {
    [self performSegueWithIdentifier:@"solarpanelstatus" sender:self];
}


- (IBAction)performLampControlSegue:(id)sender {
    
    
    if([self.flag isEqualToString:@"OFF"]){
        [[SolarCommands sharedInstance] sendSwitchOff];
        sleep(3);
//        self.flag = @"ON";
//        [self.lampONOFFButton setTitle:self.flag forState:UIControlStateNormal];
    }else{
        [[SolarCommands sharedInstance] sendSwitchOn];
        sleep(3);
//        self.flag = @"OFF";
//        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Lights will be turned on after 15s" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [alerView show];
//        [self.lampONOFFButton setTitle:self.flag forState:UIControlStateNormal];
    }
}


#pragma mark Bluetooth Delegate

- (void)stateChanged:(NSString *)string
{
    if([string containsString:@"PoweredOff"]){
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Bluetooth State" message:@"Please turn on bluetooth" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alerView show];
    }
}

- (void)valueChanged:(NSString *)string
{
                                                                  
    if([string containsString:@"Bv"]){
        self.batteryPercentageLabel.text = @"";
        
        //1Bv......1 --> Taking only dots
        NSString *val = [string substringWithRange:NSMakeRange(3, [string length]-4)];
        self.batteryVoltageLabel.text = [NSString stringWithFormat:@"%04.1fV",[val doubleValue]];
            
            //Setting the battery percent
            //Formula: ((V * 10) - 110))*2.5
//            float temp = [arr[1] floatValue];
//            temp = ((temp * 10) - 110)*2.5;
//            
//            if(temp>=100)
//                self.batteryPercentageLabel.text = [NSString stringWithFormat:@"%d%%",100];
//            else
//                self.batteryPercentageLabel.text = [NSString stringWithFormat:@"%d%%",(int)temp];
        
        
    }else if([string containsString:@"Bi"]){
        //1Bi......1 --> Taking only dots
        NSString *val = [string substringWithRange:NSMakeRange(3, [string length]-4)];
        self.batteryCurrentLabel.text = [NSString stringWithFormat:@"%04.1fA",[val doubleValue]];
        
        
    }else if([string containsString:@"Lv"]){
        //1Lv......1 --> Taking only dots
        NSString *val = [string substringWithRange:NSMakeRange(3, [string length]-4)];
        self.lampVoltageLabel.text = [NSString stringWithFormat:@"%04.1fV",[val doubleValue]];
        if([val doubleValue] >= 20.0) {
            self.flag = @"OFF";
            [self.lampONOFFButton setTitle:self.flag forState:UIControlStateNormal];
        }
        else {
            self.flag = @"ON";
            [self.lampONOFFButton setTitle:self.flag forState:UIControlStateNormal];
        }
    }else if([string containsString:@"Li"]){
        //1Li......1 --> Taking only dots
        NSString *val = [string substringWithRange:NSMakeRange(3, [string length]-4)];
        self.lampCurrentLabel.text = [NSString stringWithFormat:@"%04.1fA",[val doubleValue]];
    }else if([string containsString:@"Pi"]){
        //1Pi......1 --> Taking only dots
        NSString *val = [string substringWithRange:NSMakeRange(3, [string length]-4)];
        self.solarCurrentLabel.text = [NSString stringWithFormat:@"%04.1fA",[val doubleValue]];
    }else if([string containsString:@"Pv"]){
        //1Pv......1 --> Taking only dots
        NSString *val = [string substringWithRange:NSMakeRange(3, [string length]-4)];
        self.solarVoltageLabel.text = [NSString stringWithFormat:@"%04.1fV",[val doubleValue]];
    }else if([string containsString:@"ON"]){
        self.flag = @"OFF";
        [self.lampONOFFButton setTitle:self.flag forState:UIControlStateNormal];
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Lights will be turned on after 15s" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alerView show];
        [[SolarCommands sharedInstance] sendReadRfrsh];
    }else if([string containsString:@"OFF"]){
        self.flag = @"ON";
        [self.lampONOFFButton setTitle:self.flag forState:UIControlStateNormal];
        [[SolarCommands sharedInstance] sendReadRfrsh];
    }
//        else if([string containsString:@"SOLw"]){
//        self.solarPowerLabel.text = @"0W";
//        if([arr count]>1) self.solarPowerLabel.text = [NSString stringWithFormat:@"%@W",arr[1]];
//    }else if([string containsString:@"SYSw"]){
//        
//        
//    }

}
//
- (void) connectionStateChanged:(NSString *) string{
    if(![string containsString:@"Found"]){
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Info" message:string delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alerView show];
    }
    
}


@end
