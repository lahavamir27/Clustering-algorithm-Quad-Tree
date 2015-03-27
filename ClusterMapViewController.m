//
//  ClusterMapViewController.m
//  Google Maps iOS Example
//
//  Created by Colin Edwards on 2/1/14.
//
//

#import "ClusterMapViewController.h"

#import "Spot.h"
#import "NonHierarchicalDistanceBasedAlgorithm.h"
#import "GDefaultClusterRenderer.h"

@implementation ClusterMapViewController {
    GMSMapView *mapView;
    GClusterManager *clusterManager;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    GMSCameraPosition* camera = [GMSCameraPosition cameraWithLatitude:32.917864
                                                            longitude:35.293715
                                                                 zoom:9.5];
	
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.myLocationEnabled = NO;
    mapView.settings.myLocationButton = NO;
    mapView.settings.compassButton = NO;
    self.view = mapView;
    
    clusterManager = [GClusterManager managerWithMapView:mapView
                                               algorithm:[[NonHierarchicalDistanceBasedAlgorithm alloc] init]
                                                renderer:[[GDefaultClusterRenderer alloc] initWithMapView:mapView]];

    [mapView setDelegate:clusterManager];

    [self setDatabse];
    
    [clusterManager cluster];
}

-(void)setDatabse
{
    NSLog(@"create database with realm tech for the first time");
    
    NSString* path  = [[NSBundle mainBundle] pathForResource:@"worker" ofType:@"json"];
    
    NSString* jsonString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *jsonError;
    
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
    
    NSDictionary *arrayResult = [NSDictionary dictionary];
    
    
    for (int i=0; i<[array count]; i++) {
        arrayResult = [array objectAtIndex:i];
        
        Spot* spot = [[Spot alloc] init];
        spot.location = CLLocationCoordinate2DMake( [[arrayResult objectForKey:@"latitude"] doubleValue],[[arrayResult objectForKey:@"longitude"]  doubleValue]);
        [clusterManager addItem:spot];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
