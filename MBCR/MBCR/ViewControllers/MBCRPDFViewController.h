//
//  MBCRPDFViewController.h
//  MBCR
//
//  Created by Alex Rouse on 8/15/12.
//
//

#import <PSPDFKit/PSPDFKit.h>
#import "Bulletin.h"
#import "Manual.h"
@interface MBCRPDFViewController : PSPDFViewController <PSPDFViewControllerDelegate>
@property(nonatomic, strong) Bulletin* bulletin;
@property(nonatomic, strong) Manual* manual;

@end
