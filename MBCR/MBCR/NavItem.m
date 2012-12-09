//
//  NavItem.m
//  MBCR
//
//  Created by Lucy Li on 11/27/12.
//
//

#import "NavItem.h"

@implementation NavItem

@synthesize title=_title;
@synthesize image = _image;
@synthesize nibFileName = _nibFileName;

-(NavItem *) initWithTitle: (NSString *)titleName andImage:(UIImage *)img andNibFileName: (NSString *)nibFile
{
    _title = titleName;
    _image = img;
    _nibFileName = nibFile;
    
    return self;
}
@end
