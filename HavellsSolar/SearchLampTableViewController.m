//
//  SearchLampTableViewController.m
//  HavellsSolar
//
//  Created by Sivakumar  K R on 19/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import "SearchLampTableViewController.h"
#import "BLEDeviceTableViewCell.h"
#import "BluetoothDiscovery.h"
#import "SolarCommands.h"
@interface SearchLampTableViewController ()<BluetoothDiscoveryDelegate>

@property(strong,atomic) NSMutableArray * barButtons;
- (void) loadData;
- (void) loadUI;
@end

@implementation SearchLampTableViewController

#pragma mark Controller - UI,Data,Delegate
- (void) loadData
{
    
}

- (void) loadUI
{
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BLEDeviceTableViewCell" bundle:nil] forCellReuseIdentifier:@"BLEDeviceTableViewCell"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BKGD.png"]];
    [backgroundView setFrame:self.tableView.frame];
    [self.tableView setBackgroundView:backgroundView];
    
    if(self.loadingActivityView == nil){
        self.loadingActivityView = [[UIActivityIndicatorView alloc] initWithFrame:self.refreshBarButton.customView.frame];
        self.activityBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.loadingActivityView];
        self.activityBarButton.enabled = NO;
    }
    
    _barButtons = [[NSMutableArray alloc] initWithArray:self.navigationItem.rightBarButtonItems];
        
}
- (void) loadDelegate
{
    [[BluetoothDiscovery sharedInstance] setDiscoveryDelegate:self];
    [[BluetoothDiscovery sharedInstance] startScanningForUUIDString:nil];
    [self.tableView reloadData];
}

#pragma mark - View Delegate Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    [self loadUI];
            
//    [self performSegueWithIdentifier:@"lampcontrol" sender:self];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadDelegate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Bluetooth Discovery Delegate Methods
- (void)connectionStateChanged:(NSString *)string
{
    [self.tableView reloadData];
    
}

- (void)stateChanged:(NSString *)string
{
    if([string containsString:@"PoweredOff"]){
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Bluetooth State" message:@"Please turn on bluetooth" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alerView show];
//        BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
//        if (canOpenSettings) {
//            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//            [[UIApplication sharedApplication] openURL:url];
//        }
    }
}

- (void)valueChanged:(NSString *)string
{
    
}

- (void) isScanning:(BOOL)flag
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:self.navigationItem.rightBarButtonItems];
    if (flag){
        
        //Replace refresh button with loading spinner
        if([items containsObject:self.refreshBarButton]){
            [items replaceObjectAtIndex:[items indexOfObject:self.refreshBarButton]
                             withObject:self.activityBarButton];
            
            //Animate the loading spinner
            [self.loadingActivityView startAnimating];
        }
        
    }
    else{
        if([items containsObject:self.activityBarButton]){
            [items replaceObjectAtIndex:[items indexOfObject:self.activityBarButton]
                             withObject:self.refreshBarButton];
            [self.loadingActivityView stopAnimating];
        }
    }
    
    //Set the toolbar items
    self.navigationItem.rightBarButtonItems = items;
}



#pragma mark - Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[BluetoothDiscovery sharedInstance] foundPeripherals] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BLEDeviceTableViewCell *cell = (BLEDeviceTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"BLEDeviceTableViewCell" forIndexPath:indexPath];
    
    
    if(cell == nil){
        NSArray *temp = [[NSBundle mainBundle] loadNibNamed:@"BLEDeviceTableViewCell" owner:self options:nil];
        cell = [temp objectAtIndex:0];
        
    }
    
    NSMutableArray *peripherals = [[BluetoothDiscovery sharedInstance] foundPeripherals];
    CBPeripheral *peripheral = [peripherals objectAtIndex:indexPath.row];
    
    cell.connectButton.layer.cornerRadius = cell.connectButton.frame.size.height/2;
    cell.peripheral = peripheral;
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.lampNameLabel.text = peripheral.name;
    
    NSString *title;
    switch (peripheral.state) {
        case CBPeripheralStateConnected: title = @"Connected"; break;
        case CBPeripheralStateConnecting: title = @"Connecting"; break;
        case CBPeripheralStateDisconnecting: title = @"Disconnecting"; break;
        case CBPeripheralStateDisconnected: title = @"Connect"; break;
        default: title = @"Connect"; break;
    }
    
    [cell.connectButton setTitle:title forState:UIControlStateNormal];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BLEDeviceTableViewCell *temp = (BLEDeviceTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if(temp.peripheral.state == CBPeripheralStateConnected)
        [self performSegueWithIdentifier:@"lampcontrol" sender:self];
    else
        [temp connect:self];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - User Actions

- (IBAction)onClickRefreshButton:(id)sender {
//        [self performSegueWithIdentifier:@"lampcontrol" sender:self];

    [[BluetoothDiscovery sharedInstance] startScanningForUUIDString:nil];
}

- (IBAction)unwindToSearch:(UIStoryboardSegue *)unwindSegue
{
    NSLog(@"Coming from GREEN!");
}
@end
