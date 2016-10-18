//
//  BatteryStatusViewController.h
//  HavellsSolar
//
//  Created by Sivakumar  K R on 09/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BatteryStatusViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *batteryVoltageLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryCurrentLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryCapacityLabel;
@property (weak, nonatomic) IBOutlet UISwitch *chargingSwitch;
@property (weak, nonatomic) IBOutlet UILabel *batteryStatusLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBarButton;
@property (strong,atomic) IBOutlet UIBarButtonItem *activityBarButton;
@property (strong,atomic) NSString *batteryVoltage, * batteryCurrent,* batteryStatus;
@property (weak, nonatomic) IBOutlet UIImageView *chargingStatusImageView;
@property (strong,atomic) NSString * panelI;
@property (strong, atomic) IBOutlet UIActivityIndicatorView *loadingActivityView;
@property (weak, nonatomic) IBOutlet UILabel *chargingStatusLabel;


- (IBAction)touchUpRefresh:(id)sender;

@end
