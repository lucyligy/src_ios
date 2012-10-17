//
//  MBCRDocumentsViewController.h
//  MBCR
//
//  Created by Alex Rouse on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import "RZFileManager.h"
#import "MBCRDocumentsCell.h"

typedef enum {
    DocumentTypeManual,
    DocumentTypeBulletin
} MBCRDocumentType;

@interface MBCRDocumentsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, MBCRCellDelegate>

@property (nonatomic, strong)IBOutlet UITableView* documentTableView;
@property (nonatomic, strong)NSFetchedResultsController* documentResultsController;
@property (nonatomic, assign) MBCRDocumentType docType;

@end
