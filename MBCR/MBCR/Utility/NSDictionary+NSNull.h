//
//  NSDictionary+NSNull.h
//  MBCR
//
//  Created by Alex Rouse on 6/13/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NSNull)

-(id) validObjectForKey:(id)aKey;
-(id) validObjectForKeyPath:(id)aKeyPath;

// ensure the valuue we return is of NSNumber. We'll convert it if we can.
-(id) numberForKey:(id)aKey;

@end

