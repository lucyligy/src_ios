//
//  MBCRAVLAnnotation.h
//  MBCR
//
//  Created by Alex Rouse on 7/23/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AVL+Logic.h"


@interface MBCRAVLAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) AVL* avl;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;
@end
