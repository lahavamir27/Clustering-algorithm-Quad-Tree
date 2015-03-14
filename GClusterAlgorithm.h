#import <Foundation/Foundation.h>
#import "GClusterItem.h"

@protocol GClusterAlgorithm <NSObject>



- (void)addItem:(id <GClusterItem>) item;
- (void)removeItems;
- (double)getDistanceMeter;
- (NSSet*)getClusters:(float)zoom;

@end
