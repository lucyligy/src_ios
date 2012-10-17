//
//  MBCRBulletinCell.m
//  MBCR
//
//  Created by Alex Rouse on 7/10/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import "MBCRBulletinCell.h"
#import "Bulletin+Logic.h"
#import "RZFileManager.h"
#import "NSDate+Formatter.h"

@implementation MBCRBulletinCell
@synthesize docTitle = _docTitle;
@synthesize docDate = _docDate;
@synthesize progressView = _progressView;
@synthesize unreadIndicator = _unreadIndicator;
@synthesize bulletin = _bulletin;
@synthesize delegate = _delegate;

- (void)prepareForReuse {
    [super prepareForReuse];
    self.unreadIndicator.hidden = YES;
//    if(self.isDownloadingDocument) {
//        [[RZFileManager defaultManager] removeProgressDelegate:self fromURL:[NSURL URLWithString:self.bulletin.url]];
//    }
}

- (void)updateCellWithBulletin:(Bulletin *)bulletin {
    _bulletin = bulletin;
    self.docTitle.text = bulletin.name;
    self.docDate.text = [bulletin.expireDate fullTimeFormat];
    self.unreadIndicator.hidden = [bulletin isRead];
    if ([self isDownloadingDocument]) {
        self.progressView.hidden = NO;
        [[RZFileManager defaultManager] addProgressDelegate:self toURL:[NSURL URLWithString:bulletin.url]];
    } else {
        self.progressView.hidden = YES;
    }

}

- (BOOL)isDownloadingDocument {
    return [[[RZFileManager defaultManager] requestsWithDownloadURL:[NSURL URLWithString:self.bulletin.url]] count] > 0 ;
}

- (void)setProgress:(float)progress {
    [self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:progress] waitUntilDone:NO];
}

- (void)updateProgress:(NSNumber *)progress {
    
    [self.progressView setProgress:[progress floatValue] animated:YES];
    if ([self.progressView progress] >= 1.0) {
        self.progressView.hidden = YES;
        [self.delegate downloadFinishedForKey:self.bulletin.url];
        [[RZFileManager defaultManager] removeProgressDelegate:self fromURL:[NSURL URLWithString:self.bulletin.url]];
    }
}

@end
