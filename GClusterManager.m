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
    CLLocationCoordinate2D nearRight =vis.nearRight;
    NSLog(@"far left %f",farLeft.latitude);
    
    
    _mapWidthSize = [NSNumber numberWithDouble: floor((vis.farLeft.longitude - vis.farRight.longitude)*-1*pow(10, 5))] ;
    _mapHeightSize = [NSNumber numberWithDouble: floor((vis.nearRight.latitude - vis.farLeft.latitude)*-1*pow(10, 5))] ;

    NSLog(@"  map size in meter = %f  ",[_mapWidthSize doubleValue]);
    
    if (!_clusterLbl) {
        _clusterLbl =[[UILabel alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
        [mapView addSubview:_clusterLbl];
        _clusterLbl.backgroundColor = [UIColor whiteColor];
        
    }
    
    if (!_mapWidthLbl) {
        _mapWidthLbl =[[UILabel alloc]initWithFrame:CGRectMake(100, 130, 100, 100)];
        [mapView addSubview:_mapWidthLbl];
        _mapWidthLbl.backgroundColor = [UIColor whiteColor];
        
    }
    _mapWidthLbl.text = [NSString stringWithFormat:@"view width in meter: %d",[_mapWidthSize integerValue]];
    [_mapWidthLbl sizeToFit];
    
    if (!_mapHeightLbl) {
        _mapHeightLbl =[[UILabel alloc]initWithFrame:CGRectMake(100, 160, 100, 100)];
        [mapView addSubview:_mapHeightLbl];
        _mapHeightLbl.backgroundColor = [UIColor whiteColor];
        
    }
    _mapHeightLbl.text = [NSString stringWithFormat:@"view height in meter: %d",[_mapHeightSize integerValue]];
    [_mapHeightLbl sizeToFit];
    
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
