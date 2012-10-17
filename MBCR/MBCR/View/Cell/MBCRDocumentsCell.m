//
//  MBCRDocumentsCell.m
//  MBCR
//
//  Created by Alex Rouse on 6/18/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import "MBCRDocumentsCell.h"

@interface MBCRDocumentsCell()
@property(nonatomic, assign)float progressValue;
@property(nonatomic, strong)NSTimer* timer;

@end

@implementation MBCRDocumentsCell
@synthesize documentTitle = _documentTitle;
@synthesize progressView= _progressView;
@synthesize manual = _manual;
@synthesize requestHappening = _requestHappening;
@synthesize delegate = _delegate;

@synthesize progressValue = _progressValue;
@synthesize timer = _timer;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    self.documentTitle.text = self.manual.name;
    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
//    if(self.isDownloadingDocument) {
//        [[RZFileManager defaultManager] removeProgressDelegate:self fromURL:[NSURL URLWithString:self.manual.url]];
//        [self.progressView setProgress:0.0 animated:NO];
//    }
}

- (void)setProgress:(float)progress {
    [self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:progress] waitUntilDone:NO];
//    [self.progressView setProgress:progress animated:YES];
//    RZLog(@"progess:%f CellTitle:%@",self.progressView.progress, self.documentTitle.text);
}

- (void)updateProgress:(NSNumber *)progress {
    
    [self.progressView setProgress:[progress floatValue] animated:YES];
    if ([self.progressView progress] >= 1.0) {
        self.progressView.hidden = YES;
        [self updateTitleFrame:NO];
        [self.delegate downloadFinishedForKey:self.manual.url];
        [[RZFileManager defaultManager] removeProgressDelegate:self fromURL:[NSURL URLWithString:self.manual.url]];
    }
}

- (void)setManual:(Manual *)manual {
    _manual = manual;
    if ([self isDownloadingDocument]) {
        self.progressView.hidden = NO;
        [self updateTitleFrame:YES];
        [[RZFileManager defaultManager] addProgressDelegate:self toURL:[NSURL URLWithString:_manual.url]];
    } else {
        self.progressView.hidden = YES;
        [self updateTitleFrame:NO];
    }
    self.documentTitle.text = manual.name;
}

- (BOOL)isDownloadingDocument {
    return [[[RZFileManager defaultManager] requestsWithDownloadURL:[NSURL URLWithString:self.manual.url]] count] > 0 ;
}

- (void)updateTitleFrame:(BOOL)isDownloading {
    if (isDownloading) {
        CGRect frame = self.documentTitle.frame;
        frame.origin.y = 12;
        frame.size.height = 19;
        self.documentTitle.frame = frame;
    } else {
        CGRect frame = self.frame;
        frame.size.width = self.documentTitle.frame.size.width;
        frame.origin.x = self.documentTitle.frame.origin.x;
        frame.origin.y = 0;
        self.documentTitle.frame = frame;
    }
}

@end
