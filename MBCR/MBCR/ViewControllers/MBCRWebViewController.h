//
//  MBCRWebViewController.h
//  MBCR
//
//  Created by Alex Rouse on 7/10/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBCRWebViewController : UIViewController
@property (nonatomic, weak) IBOutlet UIWebView* webView;

- (void)loadBulletinFromURL:(NSURL *)url;

@end
