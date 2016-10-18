//
//  LampControlViewController.h
//  HavellsSolar
//
//  Created by Sivakumar  K R on 10/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LampControlViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *lampNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *geoLocationTextfield;
@property (weak, nonatomic) IBOutlet UIButton *luminairePowerButton;

@property (weak, nonatomic) IBOutlet UILabel *timerValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerStateLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButton;
@property (weak, nonatomic) IBOutlet UIPickerView *brightnessPickerView;

@property (strong,atomic) IBOutlet UIBarButtonItem *activityBarButton;

@property (strong, atomic) IBOutlet UIActivityIndicatorView *loadingActivityView;
@property (weak, nonatomic) IBOutlet UILabel *lampStateLabel;

@property(strong,nonatomic) NSString * lampName;
@property(strong,nonatomic) NSString * latlon;
@property(strong,nonatomic) NSString * selectedWatt;
@property(strong,nonatomic) NSString * selectedTimer;
@property(strong,nonatomic) NSString * selectedBrightness;

- (IBAction)touchUpSave:(id)sender;

- (void) loadUI;
@end
