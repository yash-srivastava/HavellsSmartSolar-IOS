//
//  SearchLampTableViewController.h
//  HavellsSolar
//
//  Created by Sivakumar  K R on 19/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchLampTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBarButton;
@property (strong,atomic) IBOutlet UIBarButtonItem *activityBarButton;

@property (strong, atomic) IBOutlet UIActivityIndicatorView *loadingActivityView;
- (IBAction)onClickRefreshButton:(id)sender;
@end
