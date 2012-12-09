//
//  NavItem.h
//  MBCR
//
//  Created by Lucy Li on 11/27/12.
//
//

#import <Foundation/Foundation.h>

@interface NavItem : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSString *nibFileName;

- (NavItem *) initWithTitle: (NSString *)titleName andImage:(UIImage *)img andNibFileName: (NSString *)nibFile;
@end
