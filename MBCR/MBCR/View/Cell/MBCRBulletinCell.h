//
//  MBCRBulletinCell.h
//  MBCR
//
//  Created by Alex Rouse on 7/10/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bulletin.h"
#import "MBCRDocumentsCell.h"

@interface MBCRBulletinCell : UITableViewCell <RZFileProgressDelegate>

@property (nonatomic, weak) IBOutlet UILabel* docTitle;
@property (nonatomic, weak) IBOutlet UILabel* docDate;
@property (nonatomic, weak) IBOutlet UIProgressView* progressView;
@property (nonatomic, weak) IBOutlet UIImageView* unreadIndicator;
@property (nonatomic, strong) Bulletin* bulletin;

@property (nonatomic, weak) id<MBCRCellDelegate> delegate;


- (void)updateCellWithBulletin:(Bulletin *)bulletin;
- (BOOL)isDownloadingDocument;

@end
