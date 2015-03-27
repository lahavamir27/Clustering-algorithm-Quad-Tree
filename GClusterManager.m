#import "GClusterManager.h"

@implementation GClusterManager {
    GMSCameraPosition *previousCameraPosition;
}

- (void)setMapView:(GMSMapView*)mapView {
    previousCameraPosition = nil;
    _mapView = mapView;
}

- (void)setClusterAlgorithm:(id <GClusterAlgorithm>)clusterAlgorithm {
    previousCameraPosition = nil;
    _clusterAlgorithm = clusterAlgorithm;
    
}

- (void)setClusterRenderer:(id <GClusterRenderer>)clusterRenderer {
    previousCameraPosition = nil;
    _clusterRenderer = clusterRenderer;

}

- (void)addItem:(id <GClusterItem>) item {
    [_clusterAlgorithm addItem:item];
}

- (void)removeItems {
  [_clusterAlgorithm removeItems];
}

- (void)cluster {
    NSSet *clusters = [_clusterAlgorithm getClusters:_mapView.camera.zoom];
    [_clusterRenderer clustersChanged:clusters];
    _clusterLbl.text = [NSString stringWithFormat:@"cluster size: %d meter ",(int)[_clusterAlgorithm getDistanceMeter] ];
    [_clusterLbl sizeToFit];

}


#pragma mark mapview delegate

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)cameraPosition {
    assert(mapView == _mapView);
    
    GMSProjection *proj = [[GMSProjection alloc]init];
    proj = mapView.projection;
    GMSVisibleRegion vis = [proj visibleRegion];

    CLLocationCoordinate2D farLeft = vis.farLeft;
    CLLocationCoordinate2D farRight = vis.farRight;
    
    CLLocationCoordinate2D nearRight =vis.nearRight;
    CLLocationCoordinate2D nearLeft =vis.nearLeft;

    NSLog(@"far left %f,%f",farLeft.latitude,farLeft.longitude);
    NSLog(@"far right %f,%f",farRight.latitude,farRight.longitude);

    double widthMap =pow(pow(farRight.latitude-nearRight.latitude, 2)+pow(farRight.longitude-nearRight.longitude, 2), 0.5);
    double heightMap =pow(pow(farRight.latitude-farLeft.latitude, 2)+pow(farRight.longitude-farLeft.longitude, 2), 0.5);

   
    if (!_clusterLbl)
    {
        _clusterLbl =[[UILabel alloc]initWithFrame:CGRectMake(0, 20, 100, 100)];
        [mapView addSubview:_clusterLbl];
        _clusterLbl.backgroundColor = [UIColor whiteColor];
        
    }
    
    
    // Don't re-compute clusters if the map has just been panned/tilted/rotated.
    GMSCameraPosition *position = [mapView camera];
    if (previousCameraPosition != nil && previousCameraPosition.zoom == position.zoom) {

        return;
    }

    previousCameraPosition = [mapView camera];
    
    
    [self cluster];
}

#pragma mark convenience

+ (instancetype)managerWithMapView:(GMSMapView*)googleMap
                         algorithm:(id<GClusterAlgorithm>)algorithm
                          renderer:(id<GClusterRenderer>)renderer {
    GClusterManager *mgr = [[[self class] alloc] init];
    if(mgr) {
        mgr.mapView = googleMap;
        mgr.clusterAlgorithm = algorithm;
        mgr.clusterRenderer = renderer;
    }

    return mgr;
}

@end
