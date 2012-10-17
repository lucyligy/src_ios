//
//  MBCRPDFViewController.m
//  MBCR
//
//  Created by Alex Rouse on 8/15/12.
//
//

#import "MBCRPDFViewController.h"

@interface MBCRPDFViewController ()
@property (nonatomic, strong) NSTimer* timer;

@end

@implementation MBCRPDFViewController
@synthesize timer = _timer;
@synthesize bulletin = _bulletin;
@synthesize manual = _manual;

- (void)viewDidLoad {
    self.delegate = self;
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setHidesBottomBarWhenPushed:YES];
    [self setStatusBarStyleSetting:PSPDFStatusBarIgnore];
    
}

/// delegate to be notified when pdfController finished loading
- (void)pdfViewController:(PSPDFViewController *)pdfController didDisplayDocument:(PSPDFDocument *)document {
    NSLog(@"DidDisplayDocument");
}

/// controller did show/scrolled to a new page (at least 51% of it is visible)
- (void)pdfViewController:(PSPDFViewController *)pdfController didShowPageView:(PSPDFPageView *)pageView {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(documentFail) userInfo:nil repeats:NO];
    NSLog(@"DidShowPageView");

}

/// page was fully rendered at zoomlevel = 1
- (void)pdfViewController:(PSPDFViewController *)pdfController didRenderPageView:(PSPDFPageView *)pageView {
    self.delegate = nil;
    NSLog(@"DidRenderPageView");
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)documentFail {
    NSLog(@"DocumentFail");

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}
@end
