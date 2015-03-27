#import <GoogleMaps/GoogleMaps.h>
#import "NonHierarchicalDistanceBasedAlgorithm.h"
#import "GQTBounds.h"
#import "GQTPoint.h"
#import "GStaticCluster.h"
#import "GQuadItem.h"

@implementation NonHierarchicalDistanceBasedAlgorithm {
    NSMutableArray *_items;
    GQTPointQuadTree *_quadTree;
    NSInteger _maxDistanceAtZoom;
    double kDidtance;
}

- (id)initWithMaxDistanceAtZoom:(NSInteger)aMaxDistanceAtZoom {
    if (self = [super init]) {
        _items = [[NSMutableArray alloc] init];
        _quadTree = [[GQTPointQuadTree alloc] initWithBounds:(GQTBounds){0,0,1,1}];
        _maxDistanceAtZoom = aMaxDistanceAtZoom;
    }
    return self;
}

- (id)init {
    return [self initWithMaxDistanceAtZoom:50];
}

- (void)addItem:(id <GClusterItem>) item {
    GQuadItem *quadItem = [[GQuadItem alloc] initWithItem:item];
    [_items addObject:quadItem];
    [_quadTree add:quadItem];
}

- (void)removeItems
{
  [_items removeAllObjects];
  [_quadTree clear];
}



-(void)setDistanceMeter
{
    _distance =kDidtance;
    
}

-(double)getDistanceMeter
{
    return  _distance;
}

- (NSSet*)getClusters:(float)zoom {
    int counter = 0;
    int discreteZoom = (int) zoom;
    double zoomSpecificSpan = _maxDistanceAtZoom / pow(2, discreteZoom) /200;
/*
 if (zoomSpecificSpan>0.000010) {
        zoomSpecificSpan = 0.000075;
    }
*/
    
    NSLog(@"%f zoom",zoomSpecificSpan);
    kDidtance = zoomSpecificSpan*pow(10, 7)*2;
    [self setDistanceMeter];

    NSMutableSet *visitedCandidates = [[NSMutableSet alloc] init];
    NSMutableSet *results = [[NSMutableSet alloc] init];
    NSMutableDictionary *distanceToCluster = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *itemToCluster = [[NSMutableDictionary alloc] init];
    
    for (GQuadItem* candidate in _items) {
        if ([visitedCandidates containsObject:candidate]) {
            // Candidate is already part of another cluster. prevent circle.
            continue;
        }
        
        GQTBounds bounds = [self createBoundsFromSpan:candidate.point span:zoomSpecificSpan];
        NSArray *clusterItems  = [_quadTree searchWithBounds:bounds];
        if ([clusterItems count] == 1) {
            // Only the current marker is in range. Just add the single item to the results.
            [results addObject:candidate];
            [visitedCandidates addObject:candidate];
            [distanceToCluster setObject:[NSNumber numberWithDouble:0] forKey:candidate];
            continue;
        }
        

        
        GStaticCluster *cluster = [[GStaticCluster alloc] initWithCoordinate:candidate.position];
        [results addObject:cluster];
        
        for (GQuadItem* clusterItem in clusterItems) {
            counter++;
            NSNumber *existingDistance = [distanceToCluster objectForKey:clusterItem];
            double distance = [self distanceSquared:clusterItem.point :candidate.point];
            if (existingDistance != nil) {
                // Item already belongs to another cluster. Check if it's closer to this cluster.
                if ([existingDistance doubleValue] < distance) {
                    continue;
                }
                
                // Move item to the closer cluster.
                GStaticCluster *oldCluster = [itemToCluster objectForKey:clusterItem];
                [oldCluster remove:clusterItem];
            }
            [distanceToCluster setObject:[NSNumber numberWithDouble:distance] forKey:clusterItem];
            [cluster add:clusterItem];
            [itemToCluster setObject:cluster forKey:clusterItem];
        }
        [visitedCandidates addObjectsFromArray:clusterItems];
    }
    
    return results;
}

- (double)distanceSquared:(GQTPoint) a :(GQTPoint) b {
    
    return pow(pow((a.x - b.x) , 2) + pow( (a.y - b.y), 2), 0.5) ;
}

- (GQTBounds) createBoundsFromSpan:(GQTPoint) point span:(double) span {
    double halfSpan = span / 2;
    GQTBounds bounds;
    bounds.minX = point.x - halfSpan;
    bounds.maxX = point.x + halfSpan;
    bounds.minY = point.y - halfSpan;
    bounds.maxY = point.y + halfSpan;

    return bounds;
}

@end
