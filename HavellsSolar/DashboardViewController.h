//
//  DashboardViewController.h
//  HavellsSolar
//
//  Created by Sivakumar  K R on 03/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashboardViewController : UIViewController



@property (weak, nonatomic) IBOutlet UILabel *batteryVoltageLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryCurrentLabel;
@property (weak, nonatomic) IBOutlet UILabel *solarVoltageLabel;
@property (weak, nonatomic) IBOutlet UILabel *solarCurrentLabel;
@property (weak, nonatomic) IBOutlet UILabel *solarPowerLabel;

@property (weak, nonatomic) IBOutlet UILabel *lampVoltageLabel;
@property (weak, nonatomic) IBOutlet UILabel *lampCurrentLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryPercentageLabel;
@property (weak, nonatomic) IBOutlet UIButton *lampONOFFButton;

- (IBAction)touchUpRefresh:(id)sender;
- (IBAction)touchUpDisconnect:(id)sender;
- (IBAction)lampONOFF:(id)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *tempRefreshBarButton;
@property (strong,atomic) IBOutlet UIBarButtonItem *activityBarButton;

@property (strong, atomic) IBOutlet UIActivityIndicatorView *loadingActivityView;

- (void)flipRightBarButton:(NSNumber *) flag;
- (IBAction)unwindToDashboard:(UIStoryboardSegue *)unwindSegue;

- (IBAction)performBatteryStatusSegue:(id)sender;
- (IBAction)performSolarPanelSegue:(id)sender;
- (IBAction)performLampControlSegue:(id)sender;

@end
