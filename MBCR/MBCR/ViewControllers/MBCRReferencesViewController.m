//
//  MBCRReferencesViewController.m
//  MBCR
//
//  Created by Alex Rouse on 7/3/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import "MBCRReferencesViewController.h"
#import "MBCRReferenceCell.h"
#import "MBCRDataManager.h"
#import "MBCRServiceManager.h"
#import "MBCRAppDelegate.h"
#import "UIViewFactory.h"
#import "MBCRDocumentsViewController.h"
@interface MBCRReferencesViewController ()

@end

@implementation MBCRReferencesViewController
@synthesize referenceTableView = _referenceTableView;

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
    self.navigationItem.leftBarButtonItem = [((MBCRAppDelegate *)[[UIApplication sharedApplication] delegate]) createLeftBarImage];

	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.referenceTableView reloadData];
    [self.navigationController setNavigationBarHidden:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MBCRDocumentsViewController* vc = [[MBCRDocumentsViewController alloc] initWithNibName:@"MBCRDocumentsViewController" bundle:nil];
    switch (indexPath.row) {
        case 0: {
            [[MBCRServiceManager shared] downloadBulletinList];
            vc.docType = DocumentTypeBulletin;
            vc.title = @"Bulletins";
            vc.documentResultsController = [[MBCRDataManager shared] bulletinResultsController];
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        case 1: {
            vc.docType = DocumentTypeManual;
            vc.title = @"Hot Topics";
            vc.documentResultsController = [[MBCRDataManager shared] documentsResultsControllerForManualType:kManualTypeHotTopics];
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        case 2: {
            vc.docType = DocumentTypeManual;
            vc.title = @"Manuals/Books";
            vc.documentResultsController = [[MBCRDataManager shared] documentsResultsControllerForManualType:kManualTypeManual];
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        case 3: {
            vc.docType = DocumentTypeManual;
            vc.title = @"Schedules/Run Book";
            vc.documentResultsController = [[MBCRDataManager shared] documentsResultsControllerForManualType:kManualTypeSchedule];
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        case 4: {
            vc.docType = DocumentTypeManual;
            vc.title = @"Other Notices";
            vc.documentResultsController = [[MBCRDataManager shared] documentsResultsControllerForManualType:kManualTypeOtherNotice];
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        case 5: {
            vc.docType = DocumentTypeManual;
            vc.title = @"Quick Reference";
            vc.documentResultsController = [[MBCRDataManager shared] documentsResultsControllerForManualType:kManualTypeQuickReference];
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        case 6: {
            vc.docType = DocumentTypeManual;
            vc.title = @"All Documents";
            vc.documentResultsController = [[MBCRDataManager shared] documentsResultsController];
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        default:
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49.0f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"referenceIdentifier";
    
    MBCRReferenceCell *cell = (MBCRReferenceCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = (MBCRReferenceCell *)[MBCRReferenceCell view];
    }
    cell.unreadIndicatorView.hidden = YES;
    switch (indexPath.row) {
        case 0:{
            cell.cellTitle.text = @"Bulletins/Division Notices";
            [cell setUnreadCount:[[MBCRDataManager shared] numberOfUnreadBulletins]];
        }break;
        case 1: {
            cell.cellTitle.text = @"Hot Topics";
        }break;
        case 2: {
            cell.cellTitle.text = @"Manuals/Books";
        }break;
        case 3: {
            cell.cellTitle.text = @"Schedules/Run Book";
        }break;
        case 4: {
            cell.cellTitle.text = @"Other Notices";
        }break;
        case 5: {
            cell.cellTitle.text = @"Quick Reference";
        }break;
        case 6: {
            cell.cellTitle.text = @"All Documents";
        }break;
        default:
            break;
    }
    return cell;
}

@end
