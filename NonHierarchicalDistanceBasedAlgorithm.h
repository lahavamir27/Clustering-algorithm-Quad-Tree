#import <Foundation/Foundation.h>
#import "GClusterAlgorithm.h"
#import "GQTPointQuadTree.h"

@interface NonHierarchicalDistanceBasedAlgorithm : NSObject<GClusterAlgorithm>
@property  NSInteger distance;


- (id)initWithMaxDistanceAtZoom:(NSInteger)maxDistanceAtZoom;
-(void)setDistanceMeter;

@end
