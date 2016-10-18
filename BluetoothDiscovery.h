//
//  BluetoothDiscovery.h
//  HavellsSolar
//
//  Created by Sivakumar  K R on 10/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#ifndef BluetoothDiscovery_h
#define BluetoothDiscovery_h


#endif /* BluetoothDiscovery_h */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


/***********************************************************/
/*                          UI protocols                   */
/***********************************************************/
@protocol BluetoothDiscoveryDelegate <NSObject>

- (void) stateChanged:(NSString *) string;
- (void) connectionStateChanged:(NSString *) string;
- (void) valueChanged:(NSString *) string;
- (void) isScanning:(BOOL) flag;
@end


@interface BluetoothDiscovery : NSObject

+ (id) sharedInstance;

/***********************************************************/
/*                       UI Controls                       */
/***********************************************************/

@property (strong,nonatomic) id<BluetoothDiscoveryDelegate> discoveryDelegate;

/***********************************************************/
/*                        Actions                          */
/***********************************************************/
- (void) startScanningForUUIDString:(NSString *) uuidString;
- (void) stopScanning;

- (void) connectPeripheral:(CBPeripheral *) peripheral;
- (void) disconnectPeripheral:(CBPeripheral *) peripheral;
- (BOOL) isConnected;
- (CBPeripheral *) getConnectedPeripheral;

- (void) writeCommand:(NSString *)cmd;
- (NSString *) getConnectedPeripheralName;


@property(strong,atomic) NSMutableArray *foundPeripherals,*connectedServices;

@end
