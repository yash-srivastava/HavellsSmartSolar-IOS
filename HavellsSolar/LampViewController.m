//
//  LampViewController.m
//  HavellsSolar
//
//  Created by Sivakumar  K R on 08/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import "LampViewController.h"
#import "BluetoothDiscovery.h"


@interface LampViewController () <BluetoothDiscoveryDelegate>

@end

@implementation LampViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[BluetoothDiscovery sharedInstance] setDiscoveryDelegate:self];
    [[BluetoothDiscovery sharedInstance] startScanningForUUIDString:@"4914DD84-8B51-42FD-884B-06BC9E5B96AF"];
    
    
    if(![[BluetoothDiscovery sharedInstance] isConnected] && [_searchCirlceImageView.layer animationForKey:@"rotationAnimation"] == nil){
        [self runSpinAnimationOnView:_searchCirlceImageView duration:3 rotations:1 repeat:1000];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    [self viewDidAppear:animated];
    [[BluetoothDiscovery sharedInstance] setDiscoveryDelegate:self];
    [[BluetoothDiscovery sharedInstance] startScanningForUUIDString:@"4914DD84-8B51-42FD-884B-06BC9E5B96AF"];
    
    if(![[BluetoothDiscovery sharedInstance] isConnected] && [_searchCirlceImageView.layer animationForKey:@"rotationAnimation"] == nil){
            [self runSpinAnimationOnView:_searchCirlceImageView duration:3 rotations:1 repeat:1000];
    }
    
}

- (void) connectionStateChanged:(NSString *) string{
    
    if([string containsString:@"Connected"])
        [_searchCirlceImageView.layer removeAllAnimations];
    else{
        if([_searchCirlceImageView.layer animationForKey:@"rotationAnimation"] == nil){
            [self runSpinAnimationOnView:_searchCirlceImageView duration:3 rotations:1 repeat:1000];
        }
        
    }
    
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Bluetooth State" message:string delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alerView show];
}

- (void) valueChanged:(NSString *)string
{
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    rotationAnimation.speed = .2;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
}

- (IBAction)unwindToLampSearch:(UIStoryboardSegue *)unwindSegue
{
    
}

@end
