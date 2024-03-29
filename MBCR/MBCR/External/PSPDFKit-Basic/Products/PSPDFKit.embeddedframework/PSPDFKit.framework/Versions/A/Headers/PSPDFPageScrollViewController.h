//
//  PSPDFPageScrollViewController.h
//  PSPDFKit
//
//  Copyright (c) 2012 Peter Steinberger. All rights reserved.
//

#import "PSPDFBaseViewController.h"
#import "PSPDFKitGlobal.h"
#import "PSPDFTransitionProtocol.h"
#import "PSPDFViewController.h"

@class PSPDFPageView, PSPDFPagingScrollView;

/// Basic magazine-like side scrolling.
@interface PSPDFPageScrollViewController : PSPDFBaseViewController <PSPDFTransitionProtocol, UIScrollViewDelegate>

/// Designated initializer.
- (id)initWithPDFController:(PSPDFViewController *)pdfController;

/// Associated pdfController class (hosts the UIPageViewController).
@property (nonatomic, unsafe_unretained) PSPDFViewController *pdfController;

/// Main view.
@property (nonatomic, strong, readonly) PSPDFPagingScrollView *pagingScrollView;

/// Page padding width between single/double pages.
@property (nonatomic, assign) CGFloat pagePadding;

/// Access visible page numbers or a PSPDFPageView
- (NSArray *)visiblePageNumbers;
- (PSPDFPageView *)pageViewForPage:(NSUInteger)page;

/// Set Page, animated.
- (void)setPage:(NSUInteger)page animated:(BOOL)animated;

/// Explictely reload the view.
- (void)reloadData;

@end


@interface PSPDFPageScrollViewController (PSPDFInternal)

// Rotation Helper.
@property (nonatomic, assign) NSUInteger targetPageAfterRotation;

@end

// Internally used scrollview.
@interface PSPDFPagingScrollView : UIScrollView @end
