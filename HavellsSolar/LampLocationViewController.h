//
//  LampLocationViewController.h
//  HavellsSolar
//
//  Created by Sivakumar  K R on 22/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LampLocationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *lampNameTextField;

@property (strong,atomic) NSString *lampName,*latlong;
@end
