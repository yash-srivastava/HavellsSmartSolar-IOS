//
//  SolarPanelStatusViewController.h
//  HavellsSolar
//
//  Created by Sivakumar  K R on 10/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Charts/Charts-Swift.h>

@interface SolarPanelStatusViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *voltageLabel;

@property (weak, nonatomic) IBOutlet UILabel *currentLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBarButton;

@property (strong,atomic) IBOutlet UIBarButtonItem *activityBarButton;

@property (strong, atomic) IBOutlet UIActivityIndicatorView *loadingActivityView;
@property (weak, nonatomic) IBOutlet LineChartView *lineChartView;


@property (strong,atomic) NSString * solarVoltage, *solarCurrent;
- (void)flipRightBarButton:(NSNumber *) flag;

- (void) loadUI;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
- (IBAction)touchUpRefresh:(id)sender;
@end
