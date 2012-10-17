//
//  MBCREmergencyViewController.m
//  MBCR
//
//  Created by Alex Rouse on 6/29/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import "MBCREmergencyViewController.h"

@interface MBCREmergencyViewController ()

@end

@implementation MBCREmergencyViewController

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
