//
//  BLEDeviceTableViewCell.m
//  HavellsSolar
//
//  Created by Sivakumar  K R on 19/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import "BLEDeviceTableViewCell.h"
#import "BluetoothDiscovery.h"
#import "SolarCommands.h"

@implementation BLEDeviceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)connect:(id)sender {
    if([_connectButton.titleLabel.text isEqualToString:@"Connect"]){
        [[BluetoothDiscovery sharedInstance] connectPeripheral:self.peripheral];
    }
    else{
        [[SolarCommands sharedInstance] sendUnpair];
        sleep(2);
        [[BluetoothDiscovery sharedInstance] disconnectPeripheral:self.peripheral];
    }
}
@end
