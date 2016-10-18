//
//  SolarCommands.m
//  HavellsSolar
//
//  Created by Sivakumar  K R on 29/09/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import "SolarCommands.h"
#import "BluetoothDiscovery.h"


#define HEADER "env"
#define REQUEST "1"
#define COMMAND "0"
#define READ_RFRSH "read rfrsh"
#define READ_GRAPH "read graph"
#define READ_SLONN "read slonn"
#define READ_SLOFF "read sloff"
#define READ_UPAIR "read upair"
#define READ_PAIR "read paird"
#define SET_WAT "setwat "
#define SET_BRIGHT "bright "
#define SET_DIMDURN "dimdurn "
#define SET_LOCATION "loc "
#define SET_POLE "pol "
const char DELIMITER = 0x7e;
const char STOP_BYTE = 0xf0;

@implementation SolarCommands


+(id) sharedInstance
{
    static SolarCommands *instance;
    if(instance == nil)
        instance = [[SolarCommands alloc]init];
    return instance;
}

-(char) calculateCheckSumLastByte:(NSString *)string
{
    unsigned int checkSumTotal = 0;
    const char * temp = [string cStringUsingEncoding:NSASCIIStringEncoding];
    for(int i=1;i<[string length];i++){
        checkSumTotal += (unsigned int)(temp[i]);
    }
    unsigned int modVal = checkSumTotal%100;
    if(modVal == 0) return (char)0x30;
    return (char)modVal;
}

#pragma mark - Request commands

-(void)sendReadRfrsh
{
    NSMutableString *cmd = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%c%@",DELIMITER,@HEADER]];
    [cmd appendString:@REQUEST]; //Reading
    [cmd appendString:@READ_RFRSH];
    [cmd appendString:[NSString stringWithFormat:@"%c",[self calculateCheckSumLastByte:cmd]]];
    
    if([[BluetoothDiscovery sharedInstance] isConnected])
        [[BluetoothDiscovery sharedInstance] writeCommand:cmd];
 }

-(void)sendReadGraph
{
    NSMutableString *cmd = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%c%@",DELIMITER,@HEADER]];
    [cmd appendString:@REQUEST]; //Reading
    [cmd appendString:@READ_GRAPH];
    [cmd appendString:[NSString stringWithFormat:@"%c",[self calculateCheckSumLastByte:cmd]]];
    
    if([[BluetoothDiscovery sharedInstance] isConnected])
        [[BluetoothDiscovery sharedInstance] writeCommand:cmd];
}

-(void)sendSwitchOn
{
    NSMutableString *cmd = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%c%@",DELIMITER,@HEADER]];
    [cmd appendString:@REQUEST]; //Reading
    [cmd appendString:@READ_SLONN];
    [cmd appendString:[NSString stringWithFormat:@"%c",[self calculateCheckSumLastByte:cmd]]];
    if([[BluetoothDiscovery sharedInstance] isConnected])
        [[BluetoothDiscovery sharedInstance] writeCommand:cmd];
}

-(void)sendSwitchOff
{
    NSMutableString *cmd = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%c%@",DELIMITER,@HEADER]];
    [cmd appendString:@REQUEST]; //Reading
    [cmd appendString:@READ_SLOFF];
    [cmd appendString:[NSString stringWithFormat:@"%c",[self calculateCheckSumLastByte:cmd]]];
    if([[BluetoothDiscovery sharedInstance] isConnected])
        [[BluetoothDiscovery sharedInstance] writeCommand:cmd];
}

-(void)sendUnpair
{
    
    
    NSMutableString *cmd = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%c%@",DELIMITER,@HEADER]];
    [cmd appendString:@REQUEST]; //Reading
    [cmd appendString:@READ_UPAIR];
    [cmd appendString:[NSString stringWithFormat:@"%c",[self calculateCheckSumLastByte:cmd]]];
    
    if([[BluetoothDiscovery sharedInstance] isConnected])
        [[BluetoothDiscovery sharedInstance] writeCommand:cmd];
}


-(void)sendPair
{
    NSMutableString *cmd = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%c%@",DELIMITER,@HEADER]];
    [cmd appendString:@REQUEST]; //Reading
    [cmd appendString:@READ_PAIR];
    [cmd appendString:[NSString stringWithFormat:@"%c",[self calculateCheckSumLastByte:cmd]]];
    
    if([[BluetoothDiscovery sharedInstance] isConnected])
        [[BluetoothDiscovery sharedInstance] writeCommand:cmd];
}

#pragma  end

#pragma mark Write Command

-(void)sendSetWat:(NSString *)val
{
    NSMutableString *cmd = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%c%@",DELIMITER,@HEADER]];
    [cmd appendString:@COMMAND]; //Writing
    [cmd appendString:[NSString stringWithFormat:@"%@%04.01f",@SET_WAT,[val doubleValue]]];
    [cmd appendString:[NSString stringWithFormat:@"%c",[self calculateCheckSumLastByte:cmd]]];
    
    if([[BluetoothDiscovery sharedInstance] isConnected])
        [[BluetoothDiscovery sharedInstance] writeCommand:cmd];
}

-(void)sendBrightness:(NSString *)val
{
    NSMutableString *cmd = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%c%@",DELIMITER,@HEADER]];
    [cmd appendString:@COMMAND]; //Writing
    [cmd appendString:[NSString stringWithFormat:@"%@%@",@SET_BRIGHT,val]];
    [cmd appendString:[NSString stringWithFormat:@"%c",[self calculateCheckSumLastByte:cmd]]];
    
    if([[BluetoothDiscovery sharedInstance] isConnected])
        [[BluetoothDiscovery sharedInstance] writeCommand:cmd];
}

-(void)sendDimDuration:(NSString *)val
{
    NSMutableString *cmd = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%c%@",DELIMITER,@HEADER]];
    [cmd appendString:@COMMAND]; //Writing
    [cmd appendString:[NSString stringWithFormat:@"%@%@",@SET_DIMDURN,val]];
    [cmd appendString:[NSString stringWithFormat:@"%c",[self calculateCheckSumLastByte:cmd]]];
    
    if([[BluetoothDiscovery sharedInstance] isConnected])
        [[BluetoothDiscovery sharedInstance] writeCommand:cmd];
}

-(void)sendLocation:(NSString *)val
{
    NSMutableString *cmd = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%c%@",DELIMITER,@HEADER]];
    [cmd appendString:@COMMAND]; //Writing
    [cmd appendString:[NSString stringWithFormat:@"%@%@",@SET_LOCATION,val]];
    [cmd appendString:[NSString stringWithFormat:@"%c",[self calculateCheckSumLastByte:cmd]]];
    
    if([[BluetoothDiscovery sharedInstance] isConnected])
        [[BluetoothDiscovery sharedInstance] writeCommand:cmd];
}

-(void)sendPoleNumber:(NSString *)val
{
    NSMutableString *cmd = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%c%@",DELIMITER,@HEADER]];
    [cmd appendString:@COMMAND]; //Writing
    [cmd appendString:[NSString stringWithFormat:@"%@%@",@SET_POLE,val]];
    [cmd appendString:[NSString stringWithFormat:@"%c",[self calculateCheckSumLastByte:cmd]]];
    if([[BluetoothDiscovery sharedInstance] isConnected])
        [[BluetoothDiscovery sharedInstance] writeCommand:cmd];
}


#pragma end
@end
