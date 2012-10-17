//
//  MBCRAVLAnnotation.m
//  MBCR
//
//  Created by Alex Rouse on 7/23/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import "MBCRAVLAnnotation.h"
#import "Train.h"
#import "Line.h"

@implementation MBCRAVLAnnotation 
@synthesize avl = _avl;
@synthesize title = _title;
@synthesize subtitle = _subtitle;


- (void)setAvl:(AVL *)avl {
    //Let the MapView know that we are going to be updating the position.
    [self willChangeValueForKey:@"coordinate"];
    _avl = avl;
    self.title = [NSString stringWithFormat:@"%@ %@", avl.train.line.lineDescription, avl.train.trainNo];
    self.subtitle = [NSString stringWithFormat:@"%@, %@ MPH",avl.displayLateness, avl.speed];
    [self didChangeValueForKey:@"coordinate"];
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = [self.avl.latitude doubleValue];
    theCoordinate.longitude = [self.avl.longitude doubleValue];
    return theCoordinate;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - trainNo: %@",[super description], self.avl.train.trainNo];
}
@end
