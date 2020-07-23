//
//  URLProtocol.m
//  WKWebViewWithURLProtocol
//
//  Created by Dylan on 2016/11/14.
//  Copyright © 2016年 Dylan. All rights reserved.
//

#import "URLProtocol.h"
#import "Interceptor.h"

@implementation URLProtocol

  + (BOOL)canInitWithRequest:(NSURLRequest *)request {
    return [request.URL.absoluteString containsString:@"ajax.php"];
  }

  + (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
  }

  - (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
    self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    if ( self ) {
        [NSNotificationCenter.defaultCenter postNotificationName:@"interceptor_caught" object:request];
    }
    return self;
  }

  - (void)startLoading {
      [self.client URLProtocolDidFinishLoading:self];
  }

  - (void)stopLoading {
  }

@end
