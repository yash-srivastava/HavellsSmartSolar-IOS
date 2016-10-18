//
//  TimerViewController.m
//  HavellsSolar
//
//  Created by Sivakumar  K R on 11/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import "TimerViewController.h"
#import "BluetoothDiscovery.h"
#import "LampControlViewController.h"

@interface TimerViewController () <UIPickerViewDataSource,UIPickerViewDelegate,
    BluetoothDiscoveryDelegate>



@end

@implementation TimerViewController

CGFloat fontSize;


- (void) loadValues
{
    
    NSMutableArray *dimPercentArray = [[NSMutableArray alloc] init];
    NSMutableArray *hourArray = [[NSMutableArray alloc] init];
    NSMutableArray *minArray = [[NSMutableArray alloc] init];
    for(int i=0;i<12;i++) [hourArray addObject:[NSString stringWithFormat:@"%02d HOURS",i]];
    
    for(int i=1;i<60;i++) [minArray addObject:[NSString stringWithFormat:@"%02d MINS",i]];
    
    for(int i=0;i<=100;i+=10) [dimPercentArray addObject:[NSString stringWithFormat:@"%02d%%",i]];
    
    _timerArray = [[NSArray alloc] initWithObjects:hourArray,minArray, nil];
    _dimPercentArray = [[NSArray alloc] initWithArray:dimPercentArray];
    _dimInfo = @"Lights after switched ON will be dimmed %@ after %@:%@";
    
    _selectedHours = _timerArray[0][0];
    _selectedMins = _timerArray[1][0];
    _selectedPercent = _dimPercentArray[0];
    if(UI_USER_INTERFACE_IDIOM() ==UIUserInterfaceIdiomPad)
        fontSize = 23;
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        fontSize = 12;
}

- (void) loadUI
{
    
    _dimInfoLabel.text = [NSString stringWithFormat:_dimInfo,_selectedPercent,[[_selectedHours lowercaseString] substringToIndex:2],[[_selectedMins lowercaseString] substringToIndex:2]];

}

- (void) loadDelegate
{
    self.timerPickerView.dataSource = self;
    self.timerPickerView.delegate = self;
    
    self.percentPickerView.dataSource = self;
    self.percentPickerView.delegate = self;
    
    [[BluetoothDiscovery sharedInstance] setDiscoveryDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    [self loadValues];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"setTimer"] && [segue.destinationViewController isKindOfClass:[LampControlViewController class]]){
        LampControlViewController *viewController = segue.destinationViewController;
        viewController.selectedTimer = [NSString stringWithFormat:@"%@h%@",[_selectedHours substringWithRange:NSMakeRange(0, 2)],[_selectedMins substringWithRange:NSMakeRange(0, 2)]];
        viewController.selectedBrightness = [NSString stringWithFormat:@"%03d",[[_selectedPercent substringWithRange:NSMakeRange(0,_selectedPercent.length-1)] intValue]] ;
        viewController.timerValueLabel.text = [NSString stringWithFormat:@"%@:%@",[_selectedHours substringWithRange:NSMakeRange(0, 2)],[_selectedMins substringWithRange:NSMakeRange(0, 2)]];
        if(![viewController.timerValueLabel.text isEqualToString:@""]){
            [viewController.timerValueLabel setHidden:NO];
            viewController.timerStateLabel.text = @"ON";
        }
    }
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if(pickerView == _timerPickerView)
        return 2;
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView == _timerPickerView)
        return [[_timerArray objectAtIndex:component] count];
    return [_dimPercentArray count];
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    //Hiding the pickerView separator
    [[pickerView.subviews objectAtIndex:1] setHidden:TRUE];
    [[pickerView.subviews objectAtIndex:2] setHidden:TRUE];
    pickerView.showsSelectionIndicator = NO;
    
    
    UILabel *cellView = (UILabel *)view;
    if(cellView == nil){
        cellView = [UILabel new];
    }
    cellView.textAlignment = NSTextAlignmentCenter;
    cellView.textColor = [UIColor whiteColor];
    cellView.font = [UIFont boldSystemFontOfSize:fontSize];
    
    if(pickerView == _timerPickerView)
        cellView.text = _timerArray[component][row];
    else
        cellView.text = _dimPercentArray[row];
    
    return cellView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView == _timerPickerView){
        if(component == 0)
            _selectedHours = _timerArray[component][row];
        else
            _selectedMins = _timerArray[component][row];
    }else if (pickerView == _percentPickerView){
        _selectedPercent = _dimPercentArray[row];
    }
    _dimInfoLabel.text = [NSString stringWithFormat:_dimInfo,_selectedPercent,[[_selectedHours lowercaseString] substringToIndex:2],[[_selectedMins lowercaseString] substringToIndex:2]];

    NSLog(@"%ld %ld",(long)component,(long)row);
}

#pragma mark Bluetooth Delegate
- (void)valueChanged:(NSString *)string
{
//    if([string containsString:@"Britl"]){
//        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Setting Timer" message:@"Successfull" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [alerView show];
//    }
}

- (void)stateChanged:(NSString *)string
{
    if([string containsString:@"PoweredOff"]){
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Bluetooth State" message:@"Please turn on bluetooth" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alerView show];
    }
}


- (void) connectionStateChanged:(NSString *) string{
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Bluetooth State" message:string delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alerView show];
}
@end
