//
//  TKURLRequestFilter.m
//  TKURLRequestFilter
//
//  Created by 北川達也 on 2014/08/22.
//  Copyright (c) 2014年 Tatsuya Kitagawa. All rights reserved.
//

#import "TKURLRequestFilter.h"

static NSString * const TKURLRequestFilterPassed = @"TKURLRequestFilterPassed";

@interface TKURLRequestConfiguration : NSObject

@end

@interface TKURLRequestConfiguration ()
@property (nonatomic, copy) NSString *hostName;
@property (nonatomic, copy) void (^filterHandler)(NSMutableURLRequest *);
@end

@implementation TKURLRequestConfiguration

@end

@interface TKURLRequestFilter () <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation TKURLRequestFilter

#pragma mark - Public

+ (void)registerWithHostName:(NSString *)hostName filterHandler:(void (^)(NSMutableURLRequest *))filterHandler
{
    TKURLRequestConfiguration *sharedConfiguration = [self sharedConfiguration];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [sharedConfiguration setHostName:hostName];
        [sharedConfiguration setFilterHandler:[filterHandler copy]];
        [NSURLProtocol registerClass:[self class]];
    });
}

#pragma mark - TKURLRequestConfiguration

+ (TKURLRequestConfiguration *)sharedConfiguration
{
    static dispatch_once_t onceToken;
    static TKURLRequestConfiguration *__instance = nil;
    dispatch_once(&onceToken, ^{
        __instance = [TKURLRequestConfiguration new];
    });
    return __instance;
}

#pragma mark - NSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([self propertyForKey:TKURLRequestFilterPassed inRequest:request]) {
        return NO;
    }

    return [self isTargetHostWithRequest:request] && [self validSchemeWithRequest:request];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    TKURLRequestConfiguration *sharedConfiguration = [self sharedConfiguration];
    if (sharedConfiguration.filterHandler) {
        sharedConfiguration.filterHandler(mutableRequest);
    }

    [NSURLProtocol setProperty:@(YES) forKey:TKURLRequestFilterPassed inRequest:mutableRequest];

    return mutableRequest;
}

- (void)startLoading
{
    self.connection = [[NSURLConnection alloc]
                       initWithRequest:[[self class] canonicalRequestForRequest:self.request]
                       delegate:self startImmediately:YES];
}

- (void)stopLoading
{
    [self.connection cancel];
}

#pragma mark - 

+ (BOOL)isTargetHostWithRequest:(NSURLRequest *)request
{
    TKURLRequestConfiguration *sharedConfiguration = [self sharedConfiguration];
    return [[[request URL] host] compare: sharedConfiguration.hostName] == NSOrderedSame;
}

+ (BOOL)validSchemeWithRequest:(NSURLRequest *)request
{
    return [[[request URL] scheme] caseInsensitiveCompare:@"http"] == NSOrderedSame
    || [[[request URL] scheme] caseInsensitiveCompare:@"https"] == NSOrderedSame;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [[self client] URLProtocol:self didFailWithError:error];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return YES;
}

- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection
didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:[[self request] cachePolicy]];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    [[self client] URLProtocol:self didLoadData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[self client] URLProtocolDidFinishLoading:self];
}

@end
