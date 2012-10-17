//
//  MBCRAVLDetailsViewController.h
//  MBCR
//
//  Created by Alex Rouse on 7/27/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVL.h"

@interface MBCRAVLDetailsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) AVL* avl;

@end
