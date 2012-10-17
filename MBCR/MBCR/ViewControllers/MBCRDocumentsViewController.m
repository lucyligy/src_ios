//
//  MBCRDocumentsViewController.m
//  MBCR
//
//  Created by Alex Rouse on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MBCRDocumentsViewController.h"
#import <PSPDFKit/PSPDFKit.h>
#import "Manual.h"
#import "MBCRDataManager.h"
#import "MBCRServiceManager.h"
#import "RZFileManager.h"
#import "UIViewFactory.h"
#import "MBCRBulletinCell.h"
#import "MBCRWebViewController.h"
#import "LocalyticsSession.h"
#import "MBCRPDFViewController.h"

@interface MBCRDocumentsViewController ()
@property (nonatomic, strong) NSURL* fileURL;

@property (nonatomic, strong) Manual *downloadingManual;
@property (nonatomic, strong) NSMutableDictionary* downloadingCells;

@end

@implementation MBCRDocumentsViewController
@synthesize documentTableView = _documentTableView;
@synthesize documentResultsController = _documentResultsController;
@synthesize docType = _docType;
@synthesize fileURL = _fileURL;

@synthesize downloadingManual = _downloadingManual;
@synthesize downloadingCells = _downloadingCells;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

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

- (void)viewWillAppear:(BOOL)animated {
    self.hidesBottomBarWhenPushed = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewWillAppear:animated];

}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setDocumentResultsController:(NSFetchedResultsController *)documentResultsController {
    NSError *error;
    if ([documentResultsController performFetch:&error])
    {
        _documentResultsController.delegate = nil;
        documentResultsController.delegate = self;
        _documentResultsController = documentResultsController;
        for (id item in _documentResultsController.fetchedObjects) {
            NSString* url = ([item isKindOfClass:[Manual class]]) ? ((Manual *)item).url : ((Bulletin *)item).url;
            if(!([[[RZFileManager defaultManager] requestsWithDownloadURL:[NSURL URLWithString:url]] count] > 0)) {
                [[RZFileManager defaultManager] downloadFileFromURL:[NSURL URLWithString:url] withProgressDelegate:nil enqueue:YES completion:^(BOOL success, NSURL *downloadedFile, RZWebServiceRequest *request) {}];
            }
        }
        [self.documentTableView reloadData];
    }
    else
    {
		RZLog(@"Unresolved error in MBCRDocumentsViewController %@, %@", error, [error userInfo]);
	}
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.docType == DocumentTypeManual) {
        
        Manual* manual = [self.documentResultsController objectAtIndexPath:indexPath];
        [[MBCRDataManager shared] updateOpenedDateForManual:manual];
        MBCRDocumentsCell* cell = (MBCRDocumentsCell *)[self tableView:self.documentTableView cellForRowAtIndexPath:indexPath];
        cell.progressView.hidden = NO;
        if ([[[RZFileManager defaultManager] requestsWithDownloadURL:[NSURL URLWithString:manual.url]] count] > 0) {
            //We are already downloading this file
            return;
        }
        [[RZFileManager defaultManager] downloadFileFromURL:[NSURL URLWithString:manual.url] withProgressDelegate:cell enqueue:YES completion:^(BOOL success, NSURL *downloadedFile, RZWebServiceRequest *request) {
            if([[manual.fileExtension uppercaseString] isEqualToString:kFileTypePDF]) {

                PSPDFDocument *document = [PSPDFDocument PDFDocumentWithURL:downloadedFile];
                MBCRPDFViewController *pdfController = [[MBCRPDFViewController alloc] initWithDocument:document];
                pdfController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:pdfController animated:YES];
            } else {
                MBCRWebViewController* vc = [[MBCRWebViewController alloc] init];
                UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
                navVC.title = manual.name;
                [self presentModalViewController:navVC animated:YES];
                [vc loadBulletinFromURL:downloadedFile];
            }
        }];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    manual.fileExtension, kLocalAttributeType,
                                    manual.name, kLocalAttributeName,
                                    nil];
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:kLocalActionDocumentViewed attributes:dictionary];
    } else if (self.docType == DocumentTypeBulletin) {
        Bulletin* bulletin = [self.documentResultsController objectAtIndexPath:indexPath];
        if ([[[RZFileManager defaultManager] requestsWithDownloadURL:[NSURL URLWithString:bulletin.url]] count] > 0) {
            return;
        }
        [[RZFileManager defaultManager] downloadFileFromURL:[NSURL URLWithString:bulletin.url] withProgressDelegate:nil enqueue:YES completion:^(BOOL success, NSURL *downloadedFile, RZWebServiceRequest *request) {
            if([[[[[NSURL URLWithString:bulletin.url] absoluteURL] pathExtension] uppercaseString] isEqualToString:kFileTypePDF]) {
                PSPDFDocument *document = [PSPDFDocument PDFDocumentWithURL:downloadedFile];
                MBCRPDFViewController *pdfController = [[MBCRPDFViewController alloc] initWithDocument:document];
                pdfController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:pdfController animated:YES];
            } else {
                MBCRWebViewController* vc = [[MBCRWebViewController alloc] init];
                UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
                navVC.title = bulletin.name;
                [self presentModalViewController:navVC animated:YES];
                [vc loadBulletinFromURL:downloadedFile];
            }
            [[MBCRDataManager shared] updateOpenedDateForBulletin:bulletin];


        }];
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:kLocalActionBulletinViewed attributes:nil];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.docType == DocumentTypeManual) {
        return 66.0f;
    } else {
        return 58.0f;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.documentResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.docType == DocumentTypeManual) {
        Manual* manual = [self.documentResultsController objectAtIndexPath:indexPath];
        BOOL isDownloading = NO;
        MBCRDocumentsCell*cell = [self.downloadingCells objectForKey:manual.url];
        if (cell == nil) {
            cell = (MBCRDocumentsCell *)[tableView dequeueReusableCellWithIdentifier:@"documentsIdentifier"];
        } else {
            isDownloading = YES;
        }
        if (cell == nil) {
            cell = (MBCRDocumentsCell *)[MBCRDocumentsCell view];
        }
        
        cell.manual = manual;
        if (!isDownloading && cell.isDownloadingDocument) {
            [self.downloadingCells setObject:cell forKey:manual.url];
            cell.delegate = self;
        }

        return cell;

    } else if (self.docType == DocumentTypeBulletin ) {
        
        Bulletin* bulletin = [self.documentResultsController objectAtIndexPath:indexPath];

        
        MBCRBulletinCell*cell = [self.downloadingCells objectForKey:bulletin.url];
        BOOL isDownloading = NO;
        if (cell == nil) {
            cell = (MBCRBulletinCell *)[tableView dequeueReusableCellWithIdentifier:@"bulletinIdentifier"];
        } else {
            isDownloading = YES;
        }
        if (cell == nil) {
            cell = (MBCRBulletinCell *)[MBCRBulletinCell view];
        }
        
        [cell updateCellWithBulletin:bulletin];
        
        if (!isDownloading && cell.isDownloadingDocument) {
            [self.downloadingCells setObject:cell forKey:bulletin.url];
            cell.delegate = self;
        }
        
        return cell;
        
    }
    return nil;
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.documentTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.documentTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.documentTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.documentTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.documentTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            [self.documentTableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
        case NSFetchedResultsChangeUpdate:
        {
            if (self.docType == DocumentTypeManual) {
                MBCRDocumentsCell *cell = (MBCRDocumentsCell *)[self.documentTableView cellForRowAtIndexPath:indexPath];
                cell.documentTitle.text = ((Manual *)anObject).name;
            } else if (self.docType == DocumentTypeBulletin ) {
                MBCRBulletinCell *cell = (MBCRBulletinCell *)[self.documentTableView cellForRowAtIndexPath:indexPath];
                [cell updateCellWithBulletin:(Bulletin *)anObject];
            }
        }
            break;
        default:
            //We dont really care about any other situations.
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.documentTableView endUpdates];
}

#pragma mark - MBCRCellDelegate 
- (void)downloadFinishedForKey:(NSString *)urlKey {
    [self.downloadingCells setObject:nil forKey:urlKey];
}

@end
