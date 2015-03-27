#import <CoreText/CoreText.h>
#import "GDefaultClusterRenderer.h"
#import "GQuadItem.h"
#import "GCluster.h"

@implementation GDefaultClusterRenderer {
    GMSMapView *_map;
    NSMutableArray *_markerCache;
}


- (id)initWithMapView:(GMSMapView*)googleMap {
    if (self = [super init]) {
        _map = googleMap;
        _markerCache = [[NSMutableArray alloc] init];
        
    }
    [self setLabel];

    return self;
}

- (void)clustersChanged:(NSSet*)clusters {
    for (GMSMarker *marker in _markerCache) {
        marker.map = nil;
    }
    
    NSLog(@"clsuter change");
    [_markerCache removeAllObjects];
    

    for (id <GCluster> cluster in clusters) {
        GMSMarker *marker;
        marker = [[GMSMarker alloc] init];
        [_markerCache addObject:marker];
     //   marker.appearAnimation = kGMSMarkerAnimationPop;
        NSUInteger count = cluster.items.count;
        if (count > 1) {
            marker.icon = [self generateClusterIconWithCount:count];
        }
        else {
            marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
        }
        
        marker.position = cluster.position;
        marker.map = _map;
        marker.title = [NSString stringWithFormat:@"%f, %f",cluster.position.latitude,cluster.position.longitude];
       // NSLog(@"%f, %f, %d",cluster.position.latitude,cluster.position.longitude,count);

    }
    


    
}

-(void)setLabel
{
    _lbl = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    [_map addSubview:_lbl ];
}

- (UIImage*) generateClusterIconWithCount:(NSUInteger)count {
    
    int diameter = 40;
    float inset = 2;
    int textHeight = 13;
    float textSize = 20.0f;
    
    if (count>100) {
         diameter = 60;
        textHeight = 22;
        textSize = 22.0f;

    }
    if (count<10) {
        diameter = 30;
        textHeight = 10;
        textSize = 16.0f;
        
    }
    

    
    CGRect rect = CGRectMake(0, 0, diameter, diameter);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIColor *color = [UIColor colorWithRed:212/255.0 green:83/255.0 blue:78/255.0 alpha:.9];
    // set stroking color and draw circle
    [[UIColor colorWithRed:1 green:1 blue:1 alpha:1] setStroke];
    [color setFill];

    CGContextSetLineWidth(ctx, inset);

    // make circle rect 5 px from border
    CGRect circleRect = CGRectMake(0, 0, diameter, diameter);
    circleRect = CGRectInset(circleRect, inset, inset);

    // draw circle
    CGContextFillEllipseInRect(ctx, circleRect);
    CGContextStrokeEllipseInRect(ctx, circleRect);

    CGContextSetShadow (ctx, CGSizeMake(0.0f, 2.0f), 1);
    CTFontRef myFont = CTFontCreateWithName( (CFStringRef)@"Helvetica", textSize, NULL);
    
    
    NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)myFont, (id)kCTFontAttributeName,
                    [UIColor whiteColor], (id)kCTForegroundColorAttributeName, nil ];

    // create a naked string
    NSString *string = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)count];

    
    NSAttributedString *stringToDraw = [[NSAttributedString alloc] initWithString:string
                                                                       attributes:attributesDict];

    

    
    // flip the coordinate system
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, diameter);
    CGContextScaleCTM(ctx, 1.0, -1.0);

    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(stringToDraw));
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(
                                                                        frameSetter, /* Framesetter */
                                                                        CFRangeMake(0, stringToDraw.length), /* String range (entire string) */
                                                                        NULL, /* Frame attributes */
                                                                        CGSizeMake(diameter, diameter), /* Constraints (CGFLOAT_MAX indicates unconstrained) */
                                                                        NULL /* Gives the range of string that fits into the constraints, doesn't matter in your situation */
                                                                        );
    CFRelease(frameSetter);
    
    //Get the position on the y axis
    float midHeight = diameter;
    midHeight -= suggestedSize.height;
    
    float midWidth = diameter / 2;
    midWidth -= suggestedSize.width / 2;

    CTLineRef line = CTLineCreateWithAttributedString(
            (__bridge CFAttributedStringRef)stringToDraw);
    CGContextSetTextPosition(ctx, midWidth, textHeight);
    CTLineDraw(line, ctx);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end
