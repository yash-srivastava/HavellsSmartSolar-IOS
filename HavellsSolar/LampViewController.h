//
//  LampViewController.h
//  HavellsSolar
//
//  Created by Sivakumar  K R on 08/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BluetoothDiscovery.h"

@interface LampViewController : UIViewController

@property(strong,nonatomic) BluetoothDiscovery *bluetoothDiscovery;
@property (weak, nonatomic) IBOutlet UIImageView *searchCirlceImageView;

- (IBAction)unwindToLampSearch:(UIStoryboardSegue *)unwindSegue;
@end
