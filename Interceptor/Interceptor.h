//
//  Interceptor.h
//  Interceptor
//
//  Created by Zerui Chen on 20/7/20.
//

#import <Foundation/Foundation.h>

//! Project version number for Interceptor.
FOUNDATION_EXPORT double InterceptorVersionNumber;

//! Project version string for Interceptor.
FOUNDATION_EXPORT const unsigned char InterceptorVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Interceptor/PublicHeader.h>

@interface Interceptor : NSObject

+ (void) start;
+ (void) stop;

@end
