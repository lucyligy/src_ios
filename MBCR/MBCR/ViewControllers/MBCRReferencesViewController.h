//
//  MBCRReferencesViewController.h
//  MBCR
//
//  Created by Alex Rouse on 7/3/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBCRReferencesViewController : UIViewController <UITableViewDelegate , UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView* referenceTableView;

@end
