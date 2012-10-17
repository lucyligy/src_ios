//
//  MBCRAVLMapViewController.h
//  MBCR
//
//  Created by Alex Rouse on 6/29/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MBCRServiceManager.h"
#import "MBCRPickerView.h"
#import "MBCRAVLAnnotation.h"
#import "RZHud.h"

@interface MBCRAVLMapViewController : UIViewController < NSFetchedResultsControllerDelegate, MKMapViewDelegate, MBCRPickerViewDelegate, ServiceManagerDelegate>

@property (nonatomic, weak) IBOutlet MKMapView* mapView;
@property (weak, nonatomic) IBOutlet UIButton *selectTrainButton;

//@property (nonatomic, weak) IBOutlet UIPickerView* pickerView;
@property (nonatomic, strong) NSFetchedResultsController* lineResultsController;
@property (nonatomic, strong) NSFetchedResultsController* avlResultsController;
@property (nonatomic, assign) BOOL showingFullView;

//TrainInformation Outlets
@property (nonatomic, weak) IBOutlet UIView* avlInformation;
@property (nonatomic, weak) IBOutlet UILabel* mphValue;
@property (nonatomic, weak) IBOutlet UILabel* mphLabel;
@property (nonatomic, weak) IBOutlet UILabel* statusLabel;
@property (nonatomic, weak) IBOutlet UILabel* nextStopValue;
@property (nonatomic, weak) IBOutlet UILabel* latValue;
@property (nonatomic, weak) IBOutlet UILabel* lonValue;
@property (nonatomic, weak) IBOutlet UIButton* viewToggle;
@property (weak, nonatomic) IBOutlet UIImageView *pullImageView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImage;
@property (strong, nonatomic) RZHud* hud;

- (IBAction)viewTogglePressed:(id)sender;

- (IBAction)selectTrainPressed:(id)sender;

@end
