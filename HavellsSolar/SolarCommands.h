//
//  SolarCommands.h
//  HavellsSolar
//
//  Created by Sivakumar  K R on 29/09/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SolarCommands : NSObject

-(char) calculateCheckSumLastByte:(NSString *)string;
+(id) sharedInstance;
#pragma mark - Request commands
-(void) sendReadRfrsh;
-(void)sendReadGraph;
-(void)sendSwitchOn;
-(void)sendSwitchOff;
-(void)sendUnpair;
-(void)sendPair;
#pragma  end

#pragma mark Write Commands
-(void)sendSetWat:(NSString *)val;
-(void)sendBrightness:(NSString *)val;
-(void)sendDimDuration:(NSString *)val;
-(void)sendLocation:(NSString *)val;
-(void)sendPoleNumber:(NSString *)val;
@end
