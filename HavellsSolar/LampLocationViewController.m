//
//  LampLocationViewController.m
//  HavellsSolar
//
//  Created by Sivakumar  K R on 22/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import "LampLocationViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "LampControlViewController.h"
@interface LampLocationViewController ()<CLLocationManagerDelegate,UITextFieldDelegate>
@property(strong,atomic) CLLocationManager *locationManager;
@property(strong,atomic) GMSMapView *mapView;
@end

@implementation LampLocationViewController

#pragma mark View methods
- (void) loadDelegate
{
    
    _lampNameTextField.delegate = self;
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager requestWhenInUseAuthorization];
    
    
}
- (void)loadUI {
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    
    if(_locationManager == nil) _locationManager = [[CLLocationManager alloc] init];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    _mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];    
    
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = _mapView.myLocation.coordinate;
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = _mapView;
    [self.view insertSubview:_mapView atIndex:0];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUI];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadDelegate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Textfield delegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length < 5) {
        return YES;
    }
    // allow deleting
    if (textField.text.length == 5 && string.length == 0) {
        return YES;
    }
    
    return NO;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [_lampNameTextField resignFirstResponder];
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    LampControlViewController *viewController = segue.destinationViewController;
    viewController.latlon = _latlong;
    viewController.lampName = _lampNameTextField.text;
    
    NSLog(@"%@",_lampNameTextField.text);
//    [viewController.mapButton setTitle:_latlong forState:UIControlStateNormal];
    
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    BOOL flag = YES;
    if([identifier isEqualToString:@"setLampLocation"]){
        if([_lampName isEqualToString:@""]) flag = NO;
        else if([_latlong isEqualToString:@""]) flag = NO;
    }
    return flag;
}

#pragma mark CLLocationManager Delegate

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(status == kCLAuthorizationStatusAuthorizedWhenInUse){
        [_locationManager startUpdatingLocation];
        _mapView.myLocationEnabled = YES;
        _mapView.settings.myLocationButton = YES;
    }
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation * location = [locations objectAtIndex:0];
    
    
    if(location != nil) {
        _mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate zoom:6];
        _latlong = [NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude];
     NSLog(@"lat %F lon %f",location.coordinate.latitude,location.coordinate.longitude);
    }
}
@end
