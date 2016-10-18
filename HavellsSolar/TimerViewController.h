//
//  TimerViewController.h
//  HavellsSolar
//
//  Created by Sivakumar  K R on 11/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIPickerView *timerPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *percentPickerView;
@property (weak, nonatomic) IBOutlet UILabel *dimInfoLabel;

@property (strong, nonatomic) NSArray<NSString*> *dimPercentArray;
@property (strong, nonatomic) NSArray *timerArray;
@property (strong, nonatomic) NSString *dimInfo;
@property (strong, nonatomic) NSString
*selectedHours,*selectedMins, *selectedPercent;

- (void) loadValues;
@end
