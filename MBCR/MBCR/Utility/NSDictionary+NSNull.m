//
//  NSDictionary+NSNull.m
//  MBCR
//
//  Created by Alex Rouse on 6/13/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

@implementation NSDictionary (NSNull)

-(id) validObjectForKey:(id)aKey
{
    id obj = [self objectForKey:aKey];
    if (obj == [NSNull null]) {
        obj = nil;
    }
    
    return obj;
}

-(id) validObjectForKeyPath:(id)aKeyPath
{
    id obj = [self valueForKeyPath:aKeyPath];
    if (obj == [NSNull null]) {
        obj = nil;
    }
    
    return obj;
}

-(id) numberForKey:(id)aKey
{
    id object = [self validObjectForKey:aKey];
    
    if([object isKindOfClass:[NSString class]])
    {
        NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        object = [formatter numberFromString:object];
    }
    else if(![object isKindOfClass:[NSNumber class]])
    {
        object = nil;
    }
    
    return object;
}

@end
