//
//  MBCRMoreViewController.m
//  MBCR
//
//  Created by Lucy Li on 11/27/12.
//
//

#import "MBCRMoreViewController.h"
#import "MBCRAppDelegate.h"
#import "MBCRCommentsViewController.h"
#import "MBCROTPViewController.h"


@interface MBCRMoreViewController ()

@end

@implementation MBCRMoreViewController

@synthesize moreTableView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

                                              
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    MBCRAppDelegate *appDelegate = (MBCRAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.navigationItem.leftBarButtonItem = [appDelegate createLeftBarImage];
    
    
    self.title = @"More";
    moreNavArray = [[NSMutableArray alloc] initWithObjects:nil];
    
    [self addNavItem:@"On Time Performance" ImageName:@"tab_clock" NibFileName:@"MBCROTPViewController"];
    [self addNavItem:@"Comments" ImageName:@"tab_comment" NibFileName:@"MBCRCommentsViewController"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return moreNavArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"moreNav";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NavItem *navItem = [moreNavArray objectAtIndex:indexPath.row];
    
    // Configure the cell...
    cell.textLabel.text = navItem.title;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    cell.imageView.image = navItem.image;
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.    
    NavItem *navItem = [moreNavArray objectAtIndex:indexPath.row];
    if (navItem.nibFileName == @"MBCRCommentsViewController")
    {
        MBCRCommentsViewController *commentController = [[MBCRCommentsViewController alloc] initWithNibName:nil bundle:nil];
        // ...
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:commentController animated:YES];
    }
    else if (navItem.nibFileName == @"MBCROTPViewController")

    {
        MBCROTPViewController *viewController = [[MBCROTPViewController alloc] initWithNibName:nil bundle:nil];
        
        [self.navigationController pushViewController:viewController animated:true];
    }
    
}

- (void) addNavItem:(NSString *)title ImageName:(NSString *)imageName NibFileName:(NSString *)nibName
{
    
    NavItem *navItem = [[NavItem alloc] initWithTitle:title
                                         andImage:[UIImage imageNamed:imageName]
                                   andNibFileName:nibName];
    
    [moreNavArray addObject:navItem];
    
}

@end
