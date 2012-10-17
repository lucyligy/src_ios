//
//  NSString+HMAC.h
//  Created by Craig Spitzkoff on 6/5/12.
//

#import <Foundation/Foundation.h>

@interface NSString (HMAC)

- (NSString*) HMACWithSecret:(NSString*) secret;
- (NSString*) Base64HMACWithSecret:(NSString*) secret;

@end
