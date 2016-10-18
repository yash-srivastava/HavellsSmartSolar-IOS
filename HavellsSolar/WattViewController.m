//
//  WattViewController.m
//  HavellsSolar
//
//  Created by Sivakumar  K R on 18/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import "WattViewController.h"
#import "LampControlViewController.h"
#import "BluetoothDiscovery.h"

@interface WattViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate,BluetoothDiscoveryDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *wattPickerView;
@property (weak, nonatomic) IBOutlet UITextField *wattTextField;
@property (strong, atomic) NSArray * wattArray;
@property (strong,atomic) NSString * selectedWatt;
- (IBAction)tapSomeWhere:(id)sender;

-(void) loadValues;
-(void) keyboardWasShown:(NSNotification *)notification;
-(void) keyboardWillBeHidden:(NSNotification *)notification;
@end

@implementation WattViewController
CGRect viewRect;



-(void) loadValues{
    
    _wattArray = [[NSArray alloc] initWithObjects:@"5",@"10",@"15",@"20",@"25",@"30",@"35",@"40"
                  ,@"45",@"50",@"55",@"60",nil];
    _selectedWatt = _wattArray[0];
    _wattTextField.delegate = self;
    viewRect = self.view.frame;
    
}
- (void) loadDelegate
{
    [[BluetoothDiscovery sharedInstance] setDiscoveryDelegate:self];
    _wattPickerView.delegate = self;
    _wattPickerView.dataSource = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadValues];
    
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    [self loadDelegate];
    [self registerForKeyboardNotifications];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [self unRegisterForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//     Get the new view controller using [segue destinationViewController].
//     Pass the selected object to the new view controller.
    [self assignWatt];
    if([segue.identifier isEqualToString:@"setWatt"] &&
    [segue.destinationViewController isKindOfClass:[LampControlViewController class]]){
        LampControlViewController *destinationViewController = segue.destinationViewController;
        ;
        destinationViewController.selectedWatt = [NSString stringWithFormat:@"%.1f",[_selectedWatt doubleValue]];
        [destinationViewController.luminairePowerButton setTitle:[NSString stringWithFormat:@"%@W",destinationViewController.selectedWatt] forState:UIControlStateNormal];
    }
    
    
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



#pragma mark - Picker View Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_wattArray count];
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
    
    cellView.text = _wattArray[row];
    
    return cellView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _selectedWatt = _wattArray[row];
    NSLog(@"%ld %ld",(long)component,(long)row);
}


#pragma mark - User actions

- (IBAction)tapSomeWhere:(id)sender {
    NSLog(@"wow");
    [self.wattTextField resignFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
- (void) assignWatt
{
    [self.wattTextField resignFirstResponder];
    _wattTextField.text = [_wattTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    if(![_wattTextField.text isEqualToString:@""]){
        _selectedWatt = _wattTextField.text;
    }
}


#pragma mark - Textfield Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //Assigns the text field value to selectedwatt;
    [self assignWatt];
    
    return YES;
    
}


#pragma mark - Keyboard Events Handler
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)unRegisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}
-(void) keyboardWasShown:(NSNotification *)notification
{
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= viewRect.origin.y)
    {
        [self setViewMovedUp:YES notif:notification];
    }

}
-(void) keyboardWillBeHidden:(NSNotification *)notification
{
    if (self.view.frame.origin.y < viewRect.origin.y)
    {
        [self setViewMovedUp:NO notif:notification];
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp notif:(NSNotification *) notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    
    //Get the keyboard size
    NSDictionary *userInfo = [notification userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGPoint keyboardOrigin = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        NSLog(@"Text y %f Text height %f Actual pos %f KeyboardOrg Y %f",_wattTextField.frame.origin.y,
              _wattTextField.frame.size.height,_wattTextField.frame.origin.y+_wattTextField.frame.size.height,keyboardOrigin.y);
        NSLog(@"Text y %f Text height %f Actual pos %f KeyboardOrg Y %f",_wattTextField.bounds.origin.y,
              _wattTextField.bounds.size.height,_wattTextField.bounds.origin.y+_wattTextField.bounds.size.height,keyboardOrigin.y);
        if(_wattTextField.frame.origin.y + _wattTextField.frame.size.height > keyboardOrigin.y){
            rect.origin.y -= keyboardSize.height/2;
            rect.size.height += keyboardSize.height/2;
            
        }
    }
    else
    {
        rect = viewRect;

    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

@end
