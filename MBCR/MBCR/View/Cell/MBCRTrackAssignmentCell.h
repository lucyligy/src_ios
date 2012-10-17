//
//  MBCRTrackAssignmentCell.h
//  MBCR
//
//  Created by Joe Mahon on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackAssignment.h"

@interface MBCRTrackAssignmentCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* lineLabel;
@property (nonatomic, strong) IBOutlet UILabel* trackLabel;
@property (nonatomic, strong) IBOutlet UILabel* departureLabel;
@property (nonatomic, weak) IBOutlet UILabel* statusLabel;
@property (nonatomic, strong) IBOutlet UIView* trackAssignmentView;
@property (weak, nonatomic) IBOutlet UIImageView *lightImage;

-(void)setTrackAssignment:(TrackAssignment *)assignment;
@end
