//
//  LampControlViewController.m
//  HavellsSolar
//
//  Created by Sivakumar  K R on 10/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import "LampControlViewController.h"
#import "BluetoothDiscovery.h"
#import "SolarCommands.h"

@interface LampControlViewController ()<BluetoothDiscoveryDelegate,UIAlertViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>
@property(strong,atomic) NSMutableArray * barButtons;
@property(strong,atomic) NSArray * brightnessArray;
@property(strong,atomic) NSUserDefaults *preferences;
@property(strong,atomic) NSThread *saveThread;
@property(strong,atomic) NSString *threadSuccess;

@property(strong,atomic) NSString *borderApplied;


@property(strong,atomic) NSString *brightResp, *timerResp, *wattResp, *nameResp, *latlonResp;
@end

@implementation LampControlViewController

int threadIter;

#pragma  mark View Methods
- (void) loadValues
{
    _brightnessArray = [[NSArray alloc] initWithObjects:@"10%",@"20%",@"30%",@"40%",@"50%",@"60%",@"70%",@"80%"
                  ,@"90%",@"100%",nil];
    _preferences = [NSUserDefaults standardUserDefaults];

}
-(void)viewDidLayoutSubviews
{
//    if(_borderApplied == nil){
//        //Lamp Name underline
        CALayer *border = [CALayer layer];
        CGFloat borderWidth = 1;
        border.borderColor = [UIColor whiteColor].CGColor;
        border.frame = CGRectMake(0, _lampNameTextField.frame.size.height - borderWidth, _lampNameTextField.frame.size.width, _lampNameTextField.frame.size.height);
        border.borderWidth = borderWidth;
        [_lampNameTextField.layer addSublayer:border];
        _lampNameTextField.layer.masksToBounds = YES;
//
//        //Geolocation underline
//        
        CALayer *border1 = [CALayer layer];
        border1.borderColor = [UIColor whiteColor].CGColor;
        border1.frame = CGRectMake(0, _geoLocationTextfield.frame.size.height - borderWidth, _geoLocationTextfield.frame.size.width, _geoLocationTextfield.frame.size.height);
        border1.borderWidth = borderWidth;
        [_geoLocationTextfield.layer addSublayer:border1];
        _geoLocationTextfield.layer.masksToBounds = YES;
        _borderApplied = @"";
//    }
    
}
- (void) loadUI
{
    
    if(self.loadingActivityView == nil){
        self.loadingActivityView = [[UIActivityIndicatorView alloc] initWithFrame:self.saveBarButton.customView.frame];
        self.activityBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.loadingActivityView];
        self.activityBarButton.enabled = NO;
    }
    _barButtons = [[NSMutableArray alloc] initWithArray:self.navigationItem.rightBarButtonItems];
    
    
    
    
    [_timerValueLabel setHidden:YES];
}
- (void) loadDelegate
{
    [[BluetoothDiscovery sharedInstance] setDiscoveryDelegate:self];
    _brightnessPickerView.delegate = self;
    _brightnessPickerView.dataSource = self;
    
    _lampNameTextField.delegate = self;
    _geoLocationTextfield.delegate = self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self loadUI];
    [self loadValues];
    
    [NSTimer scheduledTimerWithTimeInterval:20.0 target:[SolarCommands sharedInstance] selector:NSSelectorFromString(@"sendPair") userInfo:nil repeats:YES];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [self loadDelegate];

}
- (void)viewDidAppear:(BOOL)animated{
    NSLog(@"Selected Watt: %@",_selectedWatt);
    NSLog(@"Selected Timer: %@",_selectedTimer);
    NSLog(@"Selected Brightness: %@",_selectedBrightness);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark User Action
- (void) showAlert:(NSString *)message title:(NSString *) title
{
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alerView show];
}

- (void) saveUserDefaults
{
    if(self.selectedWatt) [_preferences setValue:self.selectedWatt forKey:@"selectedWatt"];
    
    if(self.selectedBrightness) [_preferences setValue:self.selectedBrightness forKey:@"selectedBrightness"];
    ;
    
    if(self.selectedTimer) [_preferences setValue:self.selectedTimer forKey:@"selectedTimer"];
    
//    if( self.lampName) [_preferences setValue:self.lampName forKey:@"lampName"];
    
//    if(self.latlon) [_preferences setValue:self.latlon forKey:@"latlon"];
    
    [_preferences setBool:YES forKey:@"flag"];
    [_preferences synchronize];
    
}
- (IBAction)loadUserDefaults:(id)sender {
    if(![_preferences objectForKey:@"flag"]){
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Loading Configuration failed.. Please save a configuration" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alerView show];
    }else{
        if([_preferences objectForKey:@"selectedWatt"]) {
            _selectedWatt = [NSString stringWithFormat:@"%.1f",[[_preferences objectForKey:@"selectedWatt"] doubleValue]];
            [_luminairePowerButton setTitle:[NSString stringWithFormat:@"%@W",[_preferences objectForKey:@"selectedWatt"]] forState:UIControlStateNormal];
        }
        
        
        if([_preferences objectForKey:@"selectedBrightness"]) self.selectedBrightness = [_preferences objectForKey:@"selectedBrightness"];
        if([_preferences objectForKey:@"selectedTimer"]) {self.selectedTimer = [_preferences objectForKey:@"selectedTimer"];
            NSArray *temp = [self.selectedTimer componentsSeparatedByString:@"h"];
            self.timerValueLabel.text = [NSString stringWithFormat:@"%@:%@",temp[0],temp[1]];
            if(self.selectedTimer){
                self.timerValueLabel.hidden = NO;
                self.timerStateLabel.text = @"ON";
            }
        }
        
//        if([_preferences objectForKey:@"lampName"]) {
//            self.lampName = [_preferences objectForKey:@"lampName"];
//            self.lampNameLabel.text = self.lampName;
//        }
//        if([_preferences objectForKey:@"latlon"]) {
//            self.latlon = [_preferences objectForKey:@"latlon"];
//            self.mapButton.titleLabel.text = self.latlon;
//        }
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Configuration Loaded successfully. Please save to configure" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alerView show];
    }
}


- (void) showSuccess
{
    [self saveUserDefaults];
    [self showAlert:@"Configuration saved successfully" title:@"Info"];
    [self performSegueWithIdentifier:@"dashboard" sender:self];
}

-(void) showFailure
{
    [self showAlert:@"Saving failed. Please try again" title:@"Info"];
}

- (void) executeCommand:(NSMutableArray *) commands
{
    NSArray *selectorsArray = [[NSArray alloc]initWithObjects:@"sendPoleNumber:",@"sendLocation:",@"sendBrightness:",@"sendDimDuration:",@"sendSetWat:", nil];
    
    if([commands count] != [selectorsArray count]){
        [self showAlert:@"Fields are empty" title:@"Info"];
        return;
    }
    
    [self performSelectorOnMainThread:@selector(flipRightBarButton:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];

    int i = 0;
    while(i < 2){
        _threadSuccess = @"YES";
        for (int j=0;j<[selectorsArray count];j++) {
            
            SolarCommands *temp = [SolarCommands sharedInstance];
            
            [temp performSelector:NSSelectorFromString([selectorsArray objectAtIndex:j]) withObject:[commands objectAtIndex:j]];
            
            NSLog(@"%@",[commands objectAtIndex:j]);
            sleep(3);
            if([[selectorsArray objectAtIndex:j] containsString:@"sendPoleNumber"]){
                if(!_nameResp)  { _threadSuccess = @"NO"; break; }
            }else if([[selectorsArray objectAtIndex:j] containsString:@"sendLocation"]){
                if(!_latlonResp) { _threadSuccess = @"NO"; break; }
            }else if([[selectorsArray objectAtIndex:j] containsString:@"sendBrightness"]){
                if(!_brightResp) { _threadSuccess = @"NO"; break; }
            }else if([[selectorsArray objectAtIndex:j] containsString:@"sendDimDuration"]){
                if(!_timerResp) { _threadSuccess = @"NO"; break; }
            }else if([[selectorsArray objectAtIndex:j] containsString:@"sendSetWat"]){
                if(!_wattResp) { _threadSuccess = @"NO"; break; }
            }
        }
        if([_threadSuccess isEqualToString:@"NO"]) i++;
        else
            break;
    }
    [self performSelectorOnMainThread:@selector(flipRightBarButton:) withObject:nil waitUntilDone:YES];
    
    if([_threadSuccess isEqualToString:@"YES"])
        [self performSelectorOnMainThread:@selector(showSuccess) withObject:nil waitUntilDone:YES];
    else
        [self performSelectorOnMainThread:@selector(showFailure) withObject:nil waitUntilDone:YES];

}


- (IBAction)unwindToLampControl:(UIStoryboardSegue *)unwindSegue
{
    NSLog(@"Coming from Timer!");
}
- (IBAction)lampONOFF:(id)sender {
    if([sender isOn]){
        [[SolarCommands sharedInstance]sendSwitchOn];
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Lights will be turned on after 15s" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alerView show];
        self.lampStateLabel.text = @"LUMINAIRE ON";
    }else{
        [[SolarCommands sharedInstance]sendSwitchOff];
        self.lampStateLabel.text = @"LUMINAIRE OFF";
    }
}

- (IBAction)touchUpSave:(id)sender {
    
//    [self performSegueWithIdentifier:@"dashboard" sender:self];
    
    
    NSMutableArray * values = [[NSMutableArray alloc] init];
    if(self.lampNameTextField.text == nil || [self.lampNameTextField.text containsString:@""]){ [self showAlert:@"Lamp name required" title:@"Info"]; return;}
    if(self.geoLocationTextfield.text == nil || [self.geoLocationTextfield.text containsString:@""] ) { [self showAlert:@"Lamp location required" title:@"Info"]; return;}
    if(self.selectedWatt == nil){ [self showAlert:@"Luminaire Wattage required" title:@"Info"]; return;}
    
    [values addObject:self.lampNameTextField.text];
    [values addObject:self.geoLocationTextfield.text];
    
    if([self.timerStateLabel.text isEqualToString:@"OFF"]){
        _selectedTimer = @"12h00";
        _selectedBrightness = @"100";
    }
        
    if(!self.selectedBrightness && self.selectedTimer){ [self showAlert:@"Please set timer" title:@"Info"]; return;}
    else if(self.selectedBrightness && !self.selectedTimer) { [self showAlert:@"Please set brightness" title:@"Info"]; return;}
    else if(self.selectedBrightness && self.selectedTimer){
        [values addObject:self.selectedBrightness];
        [values addObject:self.selectedTimer];
    }
    
    [values addObject:self.selectedWatt];
  
    
    
    
    if(_saveThread!=nil){
        [self.saveThread cancel];
        self.saveThread = nil;
    }
    
    _saveThread = [[NSThread alloc] initWithTarget:self selector:@selector(executeCommand:) object:values];
    _threadSuccess = 0;
    //Starting a new thread
    [self.saveThread start];
    
    
    
//    [self flipRightBarButton:[NSNumber numberWithBool:YES]];
//    int i = 1;
//    for (NSString *cmd in commands) {
//        [self performSelector:@selector(sendCommand:) withObject:cmd afterDelay:i ];
//        i+= 3;
//    }
//    [self performSelector:@selector(flipRightBarButton:) withObject:[NSNumber numberWithBool:NO] afterDelay:i ];
//    
//    [self performSelector:@selector(showSuccess) withObject:nil afterDelay:i+2];
    

}

- (void) sendCommand:(NSString *) cmd
{
    
    //Send Command
    [[BluetoothDiscovery sharedInstance] writeCommand:cmd];
    
}
- (void)flipRightBarButton:(NSNumber *) flag
{
    BOOL val = [flag boolValue];
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:self.navigationItem.rightBarButtonItems];
    if (val){
        
        //Replace refresh button with loading spinner
        if([items containsObject:self.saveBarButton]){
            [items replaceObjectAtIndex:[items indexOfObject:self.saveBarButton]
                             withObject:self.activityBarButton];
            
            //Animate the loading spinner
            [self.loadingActivityView startAnimating];
        }
        
    }
    else{
        if([items containsObject:self.activityBarButton]){
            [items replaceObjectAtIndex:[items indexOfObject:self.activityBarButton]
                             withObject:self.saveBarButton];
            [self.loadingActivityView stopAnimating];
        }
    }
    self.navigationItem.rightBarButtonItems = items;
}


#pragma mark Bluetooth Delegate
- (void)valueChanged:(NSString *)string
{
    if([string containsString:@"Wat:Set"]) self.wattResp = @"YES";
    else if([string containsString:@"SSL:Set"]) self.nameResp = @"YES";
    else if([string containsString:@"Lcation"]) self.latlonResp = @"YES";
    else if([string containsString:@"Bl"]) self.brightResp = @"YES";
    else if([string containsString:@"Tm"]) self.timerResp = @"YES";
}

- (void) connectionStateChanged:(NSString *) string{
    if(![string containsString:@"Found"])
        [self showAlert:string title:@"Info"];
    
}

- (void)stateChanged:(NSString *)string
{
    if([string containsString:@"PoweredOff"]){
        [self showAlert:@"Please turn on bluetooth" title:@"Bluetooth State"];
    }
}

#pragma mark PickerView Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_brightnessArray count];
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
    if(UI_USER_INTERFACE_IDIOM() ==UIUserInterfaceIdiomPad)
        cellView.font = [UIFont boldSystemFontOfSize:23];
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        cellView.font = [UIFont boldSystemFontOfSize:12];
    
    cellView.text = _brightnessArray[row];
    
    return cellView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _selectedBrightness = _brightnessArray[row];
    _selectedBrightness = [NSString stringWithFormat:@"%03d",[[_selectedBrightness substringWithRange:NSMakeRange(0,_selectedBrightness.length-1)] intValue]];
    NSLog(@"%ld %ld",(long)component,(long)row);
}

- (IBAction)showTimer:(id)sender {
    [self performSegueWithIdentifier:@"timer" sender:self];
}


#pragma mark Textfield delegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([self.lampNameTextField isEqual:textField]){
        if (textField.text.length < 4) {
            return YES;
        }
        // allow deleting
        if (textField.text.length == 4 && string.length == 0) {
            return YES;
        }
        return NO;
    }
    
    if([self.geoLocationTextfield isEqual:textField]){
        if (textField.text.length < 10) {
            return YES;
        }
        // allow deleting
        if (textField.text.length == 10 && string.length == 0) {
            return YES;
        }
        return NO;
    }
    
    
    return NO;
}

@end
