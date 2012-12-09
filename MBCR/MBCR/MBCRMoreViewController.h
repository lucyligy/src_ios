//
//  MBCRMoreViewController.h
//  MBCR
//
//  Created by Lucy Li on 11/27/12.
//
//

#import <UIKit/UIKit.h>
#import "NavItem.h"

@interface MBCRMoreViewController : UITableViewController
{
    NSMutableArray *moreNavArray;
/*  
    UISegmentedControl *segControl;
    NSString *_message;
    NSArray *_itemArray;    
    UIBarButtonItem *navButtonLeft;
    UIBarButtonItem *navButtonEdit;
    UIBarButtonItem *navButtonDone;
*/
}

@property (nonatomic, weak) IBOutlet UITableView *moreTableView;

@end
