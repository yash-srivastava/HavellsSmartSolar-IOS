//
//  SolarPanelStatusViewController.m
//  HavellsSolar
//
//  Created by Sivakumar  K R on 10/08/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import "SolarPanelStatusViewController.h"
#import "BluetoothDiscovery.h"
#import "Charts/Charts-Swift.h"
#import "SolarCommands.h"

//#import "HavellsSolar-Swift.h"

@interface SolarPanelStatusViewController ()<BluetoothDiscoveryDelegate,ChartViewDelegate>
@property(strong,atomic) NSMutableArray * barButtons;

@end

@implementation SolarPanelStatusViewController


#pragma mark View Methods
- (NSString *) getCurrentTime
{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"LLL dd, yyyy HH:mm:ss"];
    return [dateFormatter stringFromDate:now];
}

- (void)updateChartData
{
//    if (self.shouldHideData)
//    {
//        _lineChartView.data = nil;
//        return;
//    }
    
    [self setDataCount:5 range:35];
}

-(void)setDataCount:(int)count range:(double)range
{
    NSArray *colors = @[ChartColorTemplates.vordiplom[0], ChartColorTemplates.vordiplom[1], ChartColorTemplates.vordiplom[2]];
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        [xVals addObject:[@(i) stringValue]];
    }

    
    for (int z = 0; z < 3; z++)
    {
        NSMutableArray *values = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < count; i++)
        {
            double val = (double) (arc4random_uniform(range) + 3);
            
            [values addObject:[[ChartDataEntry alloc] initWithValue:val xIndex:i]];
            
        }
        
        
        
        LineChartDataSet *d = [[LineChartDataSet alloc] initWithYVals:values label:[NSString stringWithFormat:@"DataSet %d", z + 1]];
        if(UI_USER_INTERFACE_IDIOM() ==UIUserInterfaceIdiomPad){
            d.lineWidth = 2.5;
            d.circleRadius = 4.0;
            d.circleHoleRadius = 2.0;
            d.valueFont = [UIFont boldSystemFontOfSize:10];
        }
        else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            d.lineWidth = 1;
            d.circleRadius = 1.0;
            d.circleHoleRadius = 0.5;
            d.valueFont = [UIFont boldSystemFontOfSize:8];
        }
        
//        d.lineWidth = 2.5;
//        d.circleRadius = 4.0;
//        d.circleHoleRadius = 2.0;
        d.valueTextColor = [UIColor whiteColor];
        
        UIColor *color = colors[z % colors.count];
        [d setColor:color];
        [d setCircleColor:color];
        [dataSets addObject:d];
    }
    
//    ((LineChartDataSet *)dataSets[0]).lineDashLengths = @[@5.f, @5.f];
//    ((LineChartDataSet *)dataSets[0]).colors = ChartColorTemplates.vordiplom;
//    ((LineChartDataSet *)dataSets[0]).circleColors = ChartColorTemplates.vordiplom;
    
    LineChartData *data = [[LineChartData alloc]initWithXVals:xVals dataSets:dataSets];
    
    
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:7.f]];
    _lineChartView.data = data;
}
- (void) loadUI
{
    
    if(self.loadingActivityView == nil){
        self.loadingActivityView = [[UIActivityIndicatorView alloc] initWithFrame:self.refreshBarButton.customView.frame];
        self.activityBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.loadingActivityView];
        self.activityBarButton.enabled = NO;
    }
    _voltageLabel.text = @"Voltage:  10V";
    _currentLabel.text = @"Current:  .2A";
    _barButtons = [[NSMutableArray alloc] initWithArray:self.navigationItem.rightBarButtonItems];
    [self updateTimeLabel];
    
    
    _lineChartView.delegate = self;
    
    _lineChartView.descriptionText = @"";
    _lineChartView.noDataTextDescription = @"You need to provide data for the chart.";
    
    _lineChartView.leftAxis.enabled = YES;
    _lineChartView.leftAxis.labelTextColor = [UIColor whiteColor];
    
    
    _lineChartView.xAxis.labelPosition = XAxisLabelPositionBottom;
    _lineChartView.xAxis.labelTextColor = [UIColor whiteColor];
    
    _lineChartView.rightAxis.labelTextColor = [UIColor whiteColor];
    
    if(UI_USER_INTERFACE_IDIOM() ==UIUserInterfaceIdiomPad){
//        _lineChartView.leftAxis.labelFont = [UIFont boldSystemFontOfSize:];
        _lineChartView.leftAxis.labelFont = [UIFont boldSystemFontOfSize:10];
        _lineChartView.xAxis.labelFont = [UIFont boldSystemFontOfSize:10];
        _lineChartView.rightAxis.labelFont = [UIFont boldSystemFontOfSize:10];
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        _lineChartView.leftAxis.labelFont = [UIFont boldSystemFontOfSize:8];
        _lineChartView.xAxis.labelFont = [UIFont boldSystemFontOfSize:8];
        _lineChartView.rightAxis.labelFont = [UIFont boldSystemFontOfSize:8];
    }
//    _lineChartView.rightAxis.enabled = NO;
//    _lineChartView.rightAxis.drawAxisLineEnabled = NO;
//    _lineChartView.rightAxis.drawGridLinesEnabled = NO;
//    _lineChartView.xAxis.drawAxisLineEnabled = NO;
//    _lineChartView.xAxis.drawGridLinesEnabled = NO;
    
    _lineChartView.drawGridBackgroundEnabled = NO;
    _lineChartView.drawBordersEnabled = NO;
    _lineChartView.dragEnabled = NO;
    [_lineChartView setScaleEnabled:NO];
    _lineChartView.pinchZoomEnabled = NO;
    
    _lineChartView.legend.position = ChartLegendPositionRightOfChart;
    _lineChartView.legend.textColor = [UIColor whiteColor];
}
- (void) loadDelegate
{
    [[BluetoothDiscovery sharedInstance] setDiscoveryDelegate:self];
    [[SolarCommands sharedInstance] sendReadRfrsh];
    
    _lineChartView.delegate = self;
    [self updateChartData];
}

- (void) updateTimeLabel
{
    [_timeLabel setText:[self getCurrentTime]];
    [self performSelector:@selector(updateTimeLabel) withObject:nil afterDelay:1 ];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadDelegate];
    if(_solarVoltage!=nil && (![_solarVoltage isEqualToString:@""]))
        self.voltageLabel.text = _solarVoltage;
    if(_solarCurrent!=nil && (![_solarCurrent isEqualToString:@""]))
        self.currentLabel.text = _solarCurrent;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark Bluetooth Delegate
-(void)valueChanged:(NSString *)string
{    
    if([string containsString:@"Pi"]){
        //1Pi......1 --> Taking only dots
        NSString *val = [string substringWithRange:NSMakeRange(3, [string length]-4)];
        self.currentLabel.text = [NSString stringWithFormat:@"Current=%04.1fA",[val doubleValue]];
    }else if([string containsString:@"Pv"]){
        //1Pv......1 --> Taking only dots
        NSString *val = [string substringWithRange:NSMakeRange(3, [string length]-4)];
        self.voltageLabel.text = [NSString stringWithFormat:@"Voltage=%04.1fV",[val doubleValue]];
    }
}

- (void) connectionStateChanged:(NSString *) string{
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Info" message:string delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alerView show];
}

- (void)stateChanged:(NSString *)string
{
    if([string containsString:@"PoweredOff"]){
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Bluetooth State" message:@"Please turn on bluetooth" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alerView show];
    }
}


#pragma mark User Action
- (IBAction)touchUpRefresh:(id)sender {
    [[SolarCommands sharedInstance] sendReadRfrsh];
}

- (void) sendCommand:(NSString *) cmd
{
    //Set Activity View
    BOOL flag = YES;
    NSNumber *flagValue = [NSNumber numberWithBool:flag];
    [self flipRightBarButton:flagValue];
    
    //Send Command
    [[BluetoothDiscovery sharedInstance] writeCommand:cmd];
    
    
    //Set Refresh Button after 7 seconds
    flag = NO;
    flagValue = [NSNumber numberWithBool:flag];
    [self performSelector:@selector(flipRightBarButton:) withObject:flagValue afterDelay:7 ];
    
}
- (void)flipRightBarButton:(NSNumber *) flag
{
    BOOL val = [flag boolValue];
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:self.navigationItem.rightBarButtonItems];
    if (val){
        
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
    self.navigationItem.rightBarButtonItems = items;
}

@end
