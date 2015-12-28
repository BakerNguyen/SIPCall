//
//  LocationCell.m
//  JuzChatV2
//
//  Created by TrungVN on 8/14/13.
//  Copyright (c) 2013 mTouche. All rights reserved.
//
#import "LocationCell.h"

@implementation LocationCell

//@synthesize dicMessage;

-(void) willMoveToSuperview:(UIView *)newSuperview{
    //[self addTarget:self action:@selector(clickLocation:) forControlEvents:UIControlEventTouchUpInside];
}

/*
-(IBAction) clickLocation:(id)sender{
    NSArray *geoCoord = [[NSArray alloc] initWithArray:split([dicMessage objectForKey:@"MESSAGE"], @"|")];
    
    MapView* mapView = [[MapView alloc] initWithNibName:@"MapView" bundle:nil];
    mapView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    mapView.showPlainMap = YES;
    mapView.targetCoord = CLLocationCoordinate2DMake((CLLocationDegrees)[[geoCoord objectAtIndex:0] doubleValue],
                                                     (CLLocationDegrees)[[geoCoord objectAtIndex:1] doubleValue]);
    
    [[[ChatView share] navigationController] pushViewController:mapView animated:YES];
}
*/

@end
