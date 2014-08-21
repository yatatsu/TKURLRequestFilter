//
//  TKURLRequestFilter.h
//  TKURLRequestFilter
//
//  Created by 北川達也 on 2014/08/22.
//  Copyright (c) 2014年 Tatsuya Kitagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKURLRequestFilter : NSURLProtocol

+ (void)registerWithHostName:(NSString *)hostName
               filterHandler:(void (^)(NSMutableURLRequest *request))filterHandler;

@end