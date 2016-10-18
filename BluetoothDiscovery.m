//
//  BluetoothDiscovery.m
//  HavellsSolar
//
//  Created by Sivakumar  K R on 10/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import "BluetoothDiscovery.h"
#import "SolarCommands.h"

#define BLE_SERVICE_ID        @"4914dd84-8b51-42fd-884b-06bc9e5b96af"
#define BLE_CHAR_ID           @"05daea97-20d6-46ce-8bcd-4f3e1efe2208"

@interface BluetoothDiscovery () <CBCentralManagerDelegate,CBPeripheralDelegate>{
    CBCentralManager *centralManager;
    CBPeripheral *connectedPeripheral;
    CBCharacteristic *notificationCharacteristic;
    NSMutableString *strData;
    BOOL pendingInit;
}

@end

@implementation BluetoothDiscovery

+ (id) sharedInstance
{
    static BluetoothDiscovery * bluetoothDiscovery = nil;
    if(!bluetoothDiscovery){
        bluetoothDiscovery = [[BluetoothDiscovery alloc]init];
    }
    return bluetoothDiscovery;
}

- (id) init
{
    self = [super init];
    if(self){
        pendingInit = YES;
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerOptionShowPowerAlertKey, nil];
        centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue() options:options];
        self.foundPeripherals = [NSMutableArray new];
        self.connectedServices = [NSMutableArray new];
    }
    return self;
}

/****************************************************/
/*         Bluetooth Commands & UI Controls         */
/****************************************************/
#pragma mark - Bluetooth Command & UI controls
- (void) writeCommand:(NSString *) cmd
{
    
    NSData* data = [cmd dataUsingEncoding:NSUTF8StringEncoding];
    if(connectedPeripheral != nil){
        [connectedPeripheral writeValue:data forCharacteristic:notificationCharacteristic type:CBCharacteristicWriteWithResponse];
    }
    
}

- (NSString *) getConnectedPeripheralName
{
    if(connectedPeripheral.state == CBPeripheralStateConnected)
        return connectedPeripheral.name;
    return @"";
}



/****************************************************/
/*                      Discovery                   */
/****************************************************/
#pragma mark - Bluetooth Discovery
- (void) startScanningForUUIDString:(NSString *)uuidString
{
//    NSArray *uuidArray  = [NSArray arrayWithObjects:[CBUUID UUIDWithString:uuidString], nil];
    [_discoveryDelegate stateChanged:@"Scanning"];
//    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], CBCentralManagerOptionShowPowerAlertKey, nil];
    [centralManager scanForPeripheralsWithServices:nil options:nil];
    
    if([_discoveryDelegate respondsToSelector:@selector(isScanning:)])
        [_discoveryDelegate isScanning:YES];
}

- (void) stopScanning
{
    [_discoveryDelegate stateChanged:@"Scanning Stopped"];
    [centralManager stopScan];
    [_discoveryDelegate isScanning:NO];
}

-(BOOL) isConnected
{
    return connectedPeripheral.state == CBPeripheralStateConnected;
}

- (void) connectPeripheral:(CBPeripheral *)peripheral
{
    [self stopScanning];
    NSLog(@"Connecting Peripheral");
    
    [_discoveryDelegate connectionStateChanged:@"Connecting"];
    connectedPeripheral = peripheral;
    [centralManager connectPeripheral:peripheral options:nil];
    strData = [[NSMutableString alloc]init];
    
}

-(CBPeripheral *) getConnectedPeripheral
{
    return connectedPeripheral;
}

- (void) disconnectPeripheral:(CBPeripheral*)peripheral
{
    NSLog(@"Disconnecting Peripheral %@",peripheral.name);
//    [_discoveryDelegate connectionStateChanged:@"Disconnecting"];
    if(peripheral != nil){
        [centralManager cancelPeripheralConnection:peripheral];
    }
    
}




#pragma mark - Bluetooth CentralManager Delegate
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    if(![self.foundPeripherals containsObject:peripheral]){
        [self.foundPeripherals addObject:peripheral];
        [_discoveryDelegate connectionStateChanged:@"Found Peripheral"];
    }
    
//    NSLog(@"Discovered %@ %@",peripheral.name,peripheral.identifier);
//    for (NSString * key in advertisementData) {
//        NSLog(@"Advertising: %@ : %@",key,[advertisementData objectForKey:key]);
//    }
//    
//    NSArray *deviceServiceIdArray = [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
//    
//    if ([deviceServiceIdArray containsObject:[CBUUID UUIDWithString:BLE_SERVICE_ID]])
//    {
//        connectedPeripheral = peripheral;
//        //[self stopScanning];
//        [self connectPeripheral:peripheral];
//    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if([connectedPeripheral isEqual:peripheral]){
        NSLog(@"Connected Peripheral %@",peripheral.name);
        connectedPeripheral.delegate = self;
        [self stopScanning];
        [_discoveryDelegate connectionStateChanged:@"You have been connected to Lamp"];
        //Discovering Services
        [connectedPeripheral discoverServices:nil];                
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect %@",error);
    [_discoveryDelegate connectionStateChanged:@"Connecting to Lamp Failed. Please stay in range"];
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Disconnected Peripheral %@",peripheral.identifier);
    
    //Release the objects;
    [self.connectedServices removeAllObjects];
    [self.foundPeripherals removeAllObjects];
    connectedPeripheral = nil;
    notificationCharacteristic = nil;
    
    [_discoveryDelegate connectionStateChanged:@"Disconnected. Please connect to Street Lamp"];
    [self startScanningForUUIDString:nil];
}

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"Update state called");
    static CBCentralManagerState previousState = -1;
    
    switch ([centralManager state]) {
        case CBCentralManagerStatePoweredOff:
        {
            NSLog(@"PoweredOff");
            [_discoveryDelegate stateChanged:@"PoweredOff"];
            break;
        }
            
        case CBCentralManagerStateUnauthorized:
        {
            NSLog(@"StateUnauthorized");
            [_discoveryDelegate stateChanged:@"StateUnauthorized"];
            /* Tell user the app is not allowed. */
            break;
        }
            
        case CBCentralManagerStateUnknown:
        {
            NSLog(@"StateUnknown");
            [_discoveryDelegate stateChanged:@"StateUnknown"];
            /* Bad news, let's wait for another event. */
            break;
        }
            
        case CBCentralManagerStatePoweredOn:
        {
            NSLog(@"StatePoweredOn");
            pendingInit = NO;
            [self startScanningForUUIDString:nil];
            NSLog(@"Scanning started");

            break;
        }
            
        case CBCentralManagerStateResetting:
        {
            
            NSLog(@"StateResetting");
//            [_discoveryDelegate connectionStateChanged:@"StateResetting"];
            pendingInit = YES;
            break;
        }
            
        case CBCentralManagerStateUnsupported:
        {
            NSLog(@"StateUnsupported");
//            [_discoveryDelegate connectionStateChanged:@"StateResetting"];
            break;
        }
    }
    previousState = [centralManager state];
    
}


/******************************************************************/
/*                BLE Services and Characteristics                */
/******************************************************************/
#pragma mark - Bluetooth Peripheral Delegate
//On Discovering Services
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if(error!=nil)
        NSLog(@"Service Discovery failed %@",error);
    else{
        
        if (peripheral.state == CBPeripheralStateConnected && peripheral.services != nil) {
            
            for (CBService *service in peripheral.services) {
                
                
                //Storing the services of the peripheral
                if(![self.connectedServices containsObject:service])
                    [self.connectedServices addObject:service];
                
                NSLog(@"Service Description %@",service.description);
                
                //Discovering Characteristics
                [peripheral discoverCharacteristics:nil forService:service];
            }
        }
    }
}

//On Discovering characteristic for services
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if(error!=nil){
        NSLog(@"Characteristic Discovery failed %@",error);
    }else{
        
        for (CBCharacteristic *characteristic in service.characteristics) {
            
            NSLog(@"Service UUId %@ Characteristic Description %@",service.UUID,characteristic.description);
           
            
            //Store the characteristic for sending commands
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_CHAR_ID]]){
//            if(characteristic!=nil){
                [connectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                notificationCharacteristic = characteristic;
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error!=nil){
        NSLog(@"Value Discovery failed %@",error);
    }else{
        NSString *temp = [[NSString alloc]initWithData:characteristic.value encoding:NSASCIIStringEncoding];
        NSLog(@"Characteristic UUID %@ Characteristic Value %@",characteristic.UUID,temp);
        
        
        
        //Validation block of header and data packet
        if([temp length] == 0) return;
        
        if([temp characterAtIndex:0] == '~'){
            strData = [[NSMutableString alloc] init];
            [strData appendString:temp];
        }else{
            if(strData == nil) return;
            
            //Header received check
            if([strData length]==0 || [strData characterAtIndex:0] != '~') return;
            
            
            //Received header type and data packet type match check
            if([strData characterAtIndex:[strData length]-1] == [temp characterAtIndex:0]){
                [strData appendString:temp];
                
                
                //Validate tehc checksum value
                strData = [[NSMutableString alloc] initWithData:[strData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] encoding:NSASCIIStringEncoding];
                
                char lastByte = [[SolarCommands sharedInstance] calculateCheckSumLastByte:[strData substringWithRange:NSMakeRange(0, [strData length]-1)]];
                if(lastByte == (char)[strData characterAtIndex:[strData length]-1]){
                    //Sending updates to UI
                    [_discoveryDelegate valueChanged:temp];
                }
            }
            
            
            
            
            strData = nil;
        }
        
        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error!=nil) NSLog(@"Subscribe failed %@",error);
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error!=nil) NSLog(@"Writing value failed %@ %@",error,characteristic.UUID);
}




@end

