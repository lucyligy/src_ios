//
//  MBCRAVLMapViewController.m
//  MBCR
//
//  Created by Alex Rouse on 6/29/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import "MBCRAVLMapViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MBCRTrackAssignmentsViewController.h"
#import "Line+Display.h"
#import "AVL+Logic.h"
#import "Train.h"
#import "MBCRDataManager.h"
#import "MBCRAVLDetailsViewController.h"
#import "MBCRAppDelegate.h"


@interface MBCRAVLMapViewController ()
@property (nonatomic, strong) AVL* currentAVL;
@property (nonatomic, strong) Line* selectedLine;
@property (nonatomic, strong) NSTimer* pollTimer;
@property (nonatomic, strong) Train* selectedTrain;
@property (nonatomic, strong) NSArray* allAVL;
@property (nonatomic, strong) MBCRPickerView* pickerView;
@property (nonatomic, assign) BOOL hudLock;
@property (nonatomic, assign) MKCoordinateSpan currentSpan;
@property (nonatomic, assign) BOOL customZoomLevel;
@property (nonatomic, assign) BOOL userZoom;
@property (nonatomic, assign) BOOL finishedLoadingMap;
@end


#define kAVLPollDelay       15.0
#define kBostonRegion       MKCoordinateRegionMake(CLLocationCoordinate2DMake(42.3520, -71.0560), MKCoordinateSpanMake(0.5, 0.5))
#define kSpanTolerance      0.03
#define kAnnotationImageTag 67
#define kCurrentTrainImage  @"train_marker_light_blue_up"
#define kDefaultTrainImage  @"train_marker_purple_up"
#define kClosedTrayHeight   140
#define kOpenedTrayHeight   241

@implementation MBCRAVLMapViewController
@synthesize mapView = _mapView;
@synthesize selectTrainButton = _selectTrainButton;
@synthesize showingFullView = _showingFullView;
@synthesize avlResultsController = _avlResultsController;
@synthesize avlInformation = _avlInformation;
@synthesize mphValue = _mphValue;
@synthesize mphLabel = _mphLabel;
@synthesize statusLabel = _statusLabel;
@synthesize nextStopValue = _nextStopValue;
@synthesize latValue = _latValue;
@synthesize lonValue = _lonValue;
@synthesize viewToggle = _viewToggle;
@synthesize pullImageView = _pullImageView;
@synthesize arrowImage = _arrowImage;
@synthesize hud = _hud;

@synthesize currentAVL = _currentAVL;
@synthesize pollTimer = _pollTimer;
@synthesize selectedLine = _selectedLine;
@synthesize selectedTrain = _selectedTrain;
@synthesize allAVL = _allAVL;
@synthesize pickerView = _pickerView;
@synthesize hudLock = _hudLock;
@synthesize currentSpan = _currentSpan;
@synthesize customZoomLevel = _customZoomLevel;
@synthesize userZoom = _userZoom;
@synthesize finishedLoadingMap = _finishedLoadingMap;

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
    self.hud = [[RZHud alloc] initWithStyle:RZHudStyleBoxLoading];
    self.hud.labelText = @"Loading AVL Information...";
    self.hudLock = YES;
    [self.hud presentInView:self.view withFold:NO];
    self.customZoomLevel = NO;
    self.userZoom = NO;
    [self.mapView setRegion:kBostonRegion];
    self.mapView.showsUserLocation = YES;
    self.showingFullView = YES;
    [self viewTogglePressed:nil];
    self.avlInformation.hidden = YES;
    self.navigationItem.leftBarButtonItem = [((MBCRAppDelegate *)[[UIApplication sharedApplication] delegate]) createLeftBarImage];
    self.selectTrainButton.enabled = NO;
}

- (void)viewDidUnload
{
    [self setSelectTrainButton:nil];
    [self setPullImageView:nil];
    [self setArrowImage:nil];
    [super viewDidUnload];    
}

- (void)viewWillAppear:(BOOL)animated {
    [[MBCRServiceManager shared] downloadAVLInformationWithDelegate:self];
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = NO;
    [self.selectTrainButton setBackgroundImage:[[UIImage imageNamed:@"button_big_blue_up"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 11, 15, 11)] forState:UIControlStateNormal];
    [self.selectTrainButton setBackgroundImage:[[UIImage imageNamed:@"button_big_blue_down"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 11, 15, 11)] forState:UIControlStateHighlighted];
    
    [[LocalyticsSession sharedLocalyticsSession] tagScreen:kLocalScreenLocation];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.avlResultsController = [[MBCRDataManager shared] avlFetchResultsController];
    self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:kAVLPollDelay target:self selector:@selector(pollFired) userInfo:nil repeats:YES];
    [self.mapView setShowsUserLocation:YES];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.pollTimer invalidate];
    self.pollTimer = nil;
    [self.mapView setShowsUserLocation:NO];
}

- (void)pollFired {
    [[MBCRServiceManager shared] downloadAVLInformation];
}

- (void)showTrackAssignments {
    
    MBCRTrackAssignmentsViewController* vc = [[MBCRTrackAssignmentsViewController alloc] init];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentModalViewController:navVC animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)viewTogglePressed:(id)sender {
    if( sender != nil ) {
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:kLocalActionDropDownOpened];
    }
    CGFloat height = (self.showingFullView) ? kClosedTrayHeight : kOpenedTrayHeight;
    
    self.viewToggle.enabled = NO;
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = self.avlInformation.frame;
        frame.size.height = height;
        self.avlInformation.frame = frame;
        CGFloat radians = (!self.showingFullView) ? 0 : M_PI+0.0001;
        self.arrowImage.transform = CGAffineTransformMakeRotation(radians);
    } completion:^(BOOL finished) {
        self.showingFullView = !self.showingFullView;
        self.viewToggle.enabled = YES;

    }];
}


- (IBAction)selectTrainPressed:(id)sender {
    self.pickerView = [((MBCRAppDelegate *)[[UIApplication sharedApplication] delegate]) createPickerView];
    [self.pickerView setPickerViewType:PickerTypeAVLFilteredTrain];
    [self.pickerView setResultsController:[[MBCRDataManager shared] lineFetchResultsController]];
    [self.pickerView.picker setShowsSelectionIndicator:YES];
    self.pickerView.selectedTrain = self.selectedTrain;
    self.pickerView.selectedLine = self.selectedLine;
    [self.pickerView showView];
    self.pickerView.delegate = self;
}

#pragma mark - setter Overrides
- (void)setAvlResultsController:(NSFetchedResultsController *)avlResultsController 
{
    NSError *error;
	if ([avlResultsController performFetch:&error])
    {
        _avlResultsController.delegate = nil;
        avlResultsController.delegate = self;
        _avlResultsController = avlResultsController;     
        [self addTrainLocationsOnMapView];
        self.finishedLoadingMap = YES;
    }
    else
    {
		// Update to handle the error appropriately.
		RZLog(@"Unresolved error in avlResultsController %@, %@", error, [error userInfo]);
	}

}

- (void)setCurrentAVL:(AVL *)currentAVL {
   
    if (_currentAVL != nil && _currentAVL.train.trainNo != nil) {
        MBCRAVLAnnotation* anno = [self getAnnotationForTrainNumber:_currentAVL.train.trainNo];
        [self.mapView viewForAnnotation:anno].image = [UIImage imageNamed:kDefaultTrainImage];
        self.customZoomLevel = NO;
    }

    _currentAVL = currentAVL;
    
    [self zoomMapWithAVL:currentAVL];
    
    self.mapView.showsUserLocation = NO;
    self.avlInformation.hidden = NO;
    self.selectedTrain = currentAVL.train;
    self.selectedLine = self.selectedTrain.line;
    self.mphValue.text = [currentAVL.speed description];
    CGSize s = [self.mphValue.text sizeWithFont:self.mphValue.font];
    CGRect f = self.mphLabel.frame;
    f.origin.x = s.width + 10;
    self.mphLabel.frame = f;
    self.statusLabel.text = ([currentAVL.lateness intValue] == 0) ? @"ON TIME" : currentAVL.displayLateness;
    self.nextStopValue.text = [currentAVL.stop uppercaseString];
    self.latValue.text = [NSString stringWithFormat:@"%0.4f", [currentAVL.latitude floatValue]];
    self.lonValue.text = [NSString stringWithFormat:@"%0.4f", [currentAVL.longitude floatValue]];
    [self.selectTrainButton setTitle:[NSString stringWithFormat:@"%@ - %@",self.selectedLine.lineDescription, self.selectedTrain.trainNo] forState:UIControlStateNormal];
    MBCRAVLAnnotation* anno = [self getAnnotationForTrainNumber:_currentAVL.train.trainNo];
    [self.mapView viewForAnnotation:anno].image = [UIImage imageNamed:kCurrentTrainImage];
    
}

- (void)setHudLock:(BOOL)hudLock {
    _hudLock = hudLock;
    if (self.hud != nil && !hudLock) {
        [self.hud dismissAnimated:YES];
        self.selectTrainButton.enabled = YES;
        self.hud = nil;
    }
}

- (void)addTrainLocationsOnMapView {
    for (AVL* avl in [self.avlResultsController fetchedObjects]) {
        if ([self getAnnotationForTrainNumber:avl.train.trainNo]) {
            continue;
        }
        self.hudLock = NO;
        MBCRAVLAnnotation* annotation = [[MBCRAVLAnnotation alloc] init];
        annotation.avl = avl;
        [self.mapView addAnnotation:annotation]; 
    }
}

- (id<MKAnnotation>)getAnnotationForTrainNumber:(NSString *)trainNo {
    if (self.mapView.annotations != nil) {
        MBCRAVLAnnotation* avlAnnotation = [[self.mapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@ && avl.train.trainNo == %@",[MBCRAVLAnnotation class],trainNo]] lastObject];
        if (avlAnnotation == nil) {
            RZLog(@"Annotations: %@ trainNumber: %@",self.mapView.annotations, trainNo);
        }
        return avlAnnotation;
    }
    return nil;
}

- (void)removeOldAnnotations {
    if (self.mapView.annotations != nil) {
        NSArray* oldAnnotations = [[self.mapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@ && avl== nil",[MBCRAVLAnnotation class]]] lastObject];
        [self.mapView removeAnnotations:oldAnnotations];
    }
}

- (void)zoomMapWithAVL:(AVL *)avl {
    if (self.customZoomLevel) {
        return;
    }
    self.userZoom = NO;
    NSInteger speed = avl.speed.integerValue;
    MKCoordinateSpan span;
    if (speed == 0) {
        span = MKCoordinateSpanMake(0.005, 0.005);
    } else if (speed <= 10) {
        span = MKCoordinateSpanMake(0.01, 0.01);
    } else if (speed <=20) {
        span = MKCoordinateSpanMake(0.05, 0.05);
    } else if  (speed < 40) {
        span = MKCoordinateSpanMake(0.1, 0.1);
    } else {
        span = MKCoordinateSpanMake(0.2, 0.2);
    }
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake([avl.latitude floatValue]+ span.latitudeDelta/5, [avl.longitude floatValue]), span);
    [self.mapView setRegion:region animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
}

- (void)controller:(NSFetchedResultsController *)controller 
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo 
           atIndex:(NSUInteger)sectionIndex 
     forChangeType:(NSFetchedResultsChangeType)type
{

}


- (void)controller:(NSFetchedResultsController *)controller 
   didChangeObject:(id)anObject 
       atIndexPath:(NSIndexPath *)indexPath 
     forChangeType:(NSFetchedResultsChangeType)type 
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if ([controller isEqual:self.avlResultsController]) {
        switch(type) {
            case NSFetchedResultsChangeInsert:
            {
                self.hudLock = NO;
                AVL *avl = (AVL *)anObject;
                if (avl.train == nil) {
                    return;
                }
                MBCRAVLAnnotation* annotation = [[MBCRAVLAnnotation alloc] init];
                annotation.avl = avl;
                RZLog(@"Adding Annotation to map with AVL from Insert: %@ with TrainNo: %@ and LineDescription: %@",avl,avl.train.trainNo, avl.train.line.lineDescription);
                [self.mapView addAnnotation:annotation]; 
                
            }
                break;
            case NSFetchedResultsChangeDelete:
            {
                AVL *avl = (AVL *)anObject;
                if(avl.train == nil) {
                    
                    RZLog(@"AVL has no train: %@",avl);
                    return;
                }
                MBCRAVLAnnotation* annotation = [self getAnnotationForTrainNumber:avl.train.trainNo];
                RZLog(@"Removing Map Annotation: %@ for AVL: %@ with trainNo: %@ and lineDescription: %@",annotation,avl, avl.train.trainNo, avl.train.line.lineDescription);
                if(avl!= nil && annotation != nil) {
                    [self.mapView removeAnnotation:annotation];
                }
            }
                break;
            case NSFetchedResultsChangeMove:
                break;
            case NSFetchedResultsChangeUpdate:
            {
                AVL *avl = (AVL *)anObject;
                if (avl.train == nil) {
                    return;
                }
                MBCRAVLAnnotation* annotation = [self getAnnotationForTrainNumber:avl.train.trainNo];
                if (annotation == nil || avl.train == nil) {
                    return;
                }
                
                annotation.avl = avl;
                
                if(avl.train.trainNo == self.currentAVL.train.trainNo) {
                    self.currentAVL = avl;
                }
                
            }
                break;
            default:
                break;
        }
    } 
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self removeOldAnnotations];
}

#pragma mark- PickerViewDelegate
- (void)pickerViewDidPickValue:(MBCRPickerView *)picker {
    if(picker.selectedTrain.avl) {
        self.currentAVL = picker.selectedTrain.avl;
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
         self.currentAVL.train.line.region, kLocalAttributeRegion,
         self.currentAVL.train.line.lineDescription, kLocalAttributeLine,
         nil];
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:kLocalActionTrainSelected attributes:dictionary];
    }
}
- (void)pickerViewDidCancel:(MBCRPickerView *)picker {
    
}

#pragma mark - MKMapViewDelegate Methods
- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated {
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *pinAnnotation = nil;
    if(annotation != self.mapView.userLocation) 
    {
        static NSString *defaultPinID = @"avlPin";
        pinAnnotation = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinAnnotation == nil ) {
            pinAnnotation = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
            pinAnnotation.frame = CGRectMake(0, 0, 30, 30);
            MBCRAVLAnnotation* avlAnnotation = (MBCRAVLAnnotation *)annotation;
            UIImage* trainIcon = nil;
            if (self.currentAVL.train.trainNo != nil && avlAnnotation.avl.train.trainNo == self.currentAVL.train.trainNo) {
                trainIcon = [UIImage imageNamed:kCurrentTrainImage];
            } else {
                trainIcon = [UIImage imageNamed:kDefaultTrainImage];
            }
            pinAnnotation.image = trainIcon;


        }
        pinAnnotation.canShowCallout = YES;
        
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinAnnotation.rightCalloutAccessoryView = infoButton;
    }
    
    return pinAnnotation;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if(view.annotation != mapView.userLocation) {
        MBCRAVLDetailsViewController* detailsVC = [[MBCRAVLDetailsViewController alloc] init];
        detailsVC.avl = ((MBCRAVLAnnotation *) view.annotation).avl;
        self.hidesBottomBarWhenPushed = NO;
        [self.navigationController pushViewController:detailsVC animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (view.annotation != mapView.userLocation) {
        MBCRAVLAnnotation* anno = (MBCRAVLAnnotation *) view.annotation;
        AVL* tappedAVL = anno.avl;
        self.userZoom = NO;
        CGFloat offset = (self.showingFullView) ? (self.mapView.region.span.latitudeDelta*(0.41)) : (self.mapView.region.span.latitudeDelta/5);
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(([tappedAVL.latitude floatValue]+offset) , [tappedAVL.longitude floatValue]) animated:YES];
        

        [[LocalyticsSession sharedLocalyticsSession] tagEvent:kLocalActionTrainTapped];
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    MKAnnotationView *aV; 
    float delay = 0.00;
    
    for (aV in views) {
        CGRect endFrame = aV.frame;
        
        aV.frame = CGRectMake(aV.frame.origin.x+(aV.frame.size.width/2), aV.frame.origin.y + (aV.frame.size.height/2), 0, 0);
        delay = delay + 0.01;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:delay];
        [UIView setAnimationDuration:0.20];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [aV setFrame:endFrame];
        [UIView commitAnimations];
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    self.currentSpan = mapView.region.span;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (fabs((mapView.region.span.latitudeDelta - self.currentSpan.latitudeDelta))  > kSpanTolerance ) {
        if (self.userZoom && self.finishedLoadingMap) {
            self.customZoomLevel = YES;
        } else {
            self.userZoom = YES;
        }
    }
}

#pragma mark ServiceManagerDelegate Methods
-(void)webRequestSucceeded:(id)data request:(RZWebServiceRequest *)request {
//    [self.hud dismissAnimated:YES];
}

- (void)webRequestFailed:(NSError *)error request:(RZWebServiceRequest *)request {
    if([[self.avlResultsController fetchedObjects] count] < 1) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error Getting AVL" message:@"There was a problem getting avl information.  Make sure that you have internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    [self.hud dismissAnimated:YES];
}

@end
