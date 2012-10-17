//
//  MBCRDocumentsCell.h
//  MBCR
//
//  Created by Alex Rouse on 6/18/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Manual.h"
#import "RZFileManager.h"

@protocol MBCRCellDelegate <NSObject>

- (void)downloadFinishedForKey:(NSString *)urlKey;

@end

@interface MBCRDocumentsCell : UITableViewCell <RZFileProgressDelegate> 

@property (nonatomic, strong) IBOutlet UILabel* documentTitle;
@property (nonatomic, strong) IBOutlet UIProgressView* progressView;

@property (nonatomic, strong) Manual* manual;
@property (nonatomic, assign) BOOL requestHappening;
@property (nonatomic, weak) id<MBCRCellDelegate> delegate;
- (BOOL)isDownloadingDocument;

@end
