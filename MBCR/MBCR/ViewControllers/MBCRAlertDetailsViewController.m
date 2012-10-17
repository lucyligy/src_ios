//
//  MBCRAlertDetailsViewController.m
//  MBCR
//
//  Created by Alex Rouse on 6/15/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import "MBCRAlertDetailsViewController.h"
#import "Line.h"
#import "NSDate+Formatter.h"
#import "MBCRAppDelegate.h"
#import "AllPageAlert.h"
#import "UIColor+MBCRColors.h"


@interface MBCRAlertDetailsViewController ()

@end

@implementation MBCRAlertDetailsViewController
@synthesize messageTextView = _messageTextView;
@synthesize sentDateLabel = _sentDateLabel;
@synthesize lineLabel = _lineLabel;
@synthesize alertTypeView = _alertTypeView;
@synthesize alertColor = _alertColor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Alert Details";
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setLineLabel:nil];
    [self setAlertTypeView:nil];
    [self setAlertColor:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[LocalyticsSession sharedLocalyticsSession] tagScreen:kLocalScreenMessageDetails];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)updateViewWithAlert:(MBCRAlert *)alert {
    self.messageTextView.text = alert.message;
    self.sentDateLabel.text = [alert.receivedOn clockTimeFormat];
    if ([[alert line] count] > 0) {
        self.lineLabel.text = [[[alert line] anyObject] lineDescription];
    } else {
        self.lineLabel.text = @"No Line";
    }
    if([alert isKindOfClass:[AllPageAlert class]]) {
        self.alertTypeView.backgroundColor = [UIColor MBCRAllPageColor];
    } else {
        self.alertTypeView.backgroundColor = [UIColor whiteColor];
    }
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                ([alert isKindOfClass:[AllPageAlert class]]) ? @"AllPage" : @"TAlert" , kLocalAttributeType,
                                nil];
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:kLocalActionMessageViewed attributes:dictionary];
}

- (void)updateViewWithSubwayAlert:(SubwayAlert *)alert {
    self.messageTextView.text = alert.message;
    self.sentDateLabel.text = [alert.receivedOn clockTimeFormat];
    if ([[alert line] length] > 0) {
        self.lineLabel.text = [NSString stringWithFormat:@"%@ Line",[alert line]];
    } else {
        self.lineLabel.text = @"No Line";
    }
    
    if ([alert.line isEqualToString:kSubwayGreenLineKey]) {
        self.alertColor.image = [UIImage imageNamed:@"green_line_cell_indicator"];
    } else if ([alert.line isEqualToString:kSubwayRedLineKey]) {
        self.alertColor.image = [UIImage imageNamed:@"red_line_cell_indicator"];
    } else if ([alert.line isEqualToString:kSubwayBlueLineKey]) {
        self.alertColor.image = [UIImage imageNamed:@"blue_line_cell_indicator"];
    } else if ([alert.line isEqualToString:kSubwayOrangeLineKey]) {
        self.alertColor.image = [UIImage imageNamed:@"orange_line_cell_indicator"];
    } else if ([alert.line isEqualToString:kSubwaySilverLineKey]) {
        self.alertColor.image = [UIImage imageNamed:@"silver_line_cell_indicator"];
    } else {
        self.alertColor.image = nil;
    }

    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys: (alert.line) ? alert.line : @"No Line", kLocalAttributeLine, nil];
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:kLocalActionSubwayMessageViewed attributes:dictionary];
}

@end
