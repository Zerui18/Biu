//
//  Interceptor.m
//  Interceptor
//
//  Created by Zerui Chen on 20/7/20.
//

#import <Foundation/Foundation.h>
#import "Interceptor.h"
#import "URLProtocol.h"
#import "NSURLProtocol+WKWebViewSupport.h"

static Interceptor *interceptor;

@implementation Interceptor

+ (void) start {
    [NSURLProtocol wk_registerScheme:@"http"];
    [NSURLProtocol wk_registerScheme:@"https"];

    [NSURLProtocol registerClass:[URLProtocol class]];
}

+ (void) stop {
    [NSURLProtocol wk_unregisterScheme:@"http"];
    [NSURLProtocol wk_unregisterScheme:@"https"];
    
    [NSURLProtocol unregisterClass:[URLProtocol class]];
}

@end
