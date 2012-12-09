//
//  MBCRCommentsViewController.m
//  MBCR
//
//  Created by Alex Rouse on 6/29/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import "MBCRCommentsViewController.h"
#import "MBCRAppDelegate.h"


@interface MBCRCommentsViewController ()

@end

@implementation MBCRCommentsViewController
@synthesize webView = _webView;


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
	// Do any additional setup after loading the view.
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:kCommentsPageURL]];
    [self.webView loadRequest:request];
    self.navigationItem.leftBarButtonItem = [((MBCRAppDelegate *)[[UIApplication sharedApplication] delegate]) createLeftBarImage];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
