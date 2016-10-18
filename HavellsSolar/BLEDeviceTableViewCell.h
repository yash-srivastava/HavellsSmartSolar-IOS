//
//  BLEDeviceTableViewCell.h
//  HavellsSolar
//
//  Created by Sivakumar  K R on 19/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEDeviceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (strong, atomic) IBOutlet UILabel *lampNameLabel;
@property (strong,atomic) CBPeripheral * peripheral;

- (IBAction)connect:(id)sender;

@end
