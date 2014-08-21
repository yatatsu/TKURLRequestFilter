//
//  ViewController.m
//  TKURLRequestFilter
//
//  Created by 北川達也 on 2014/08/21.
//  Copyright (c) 2014年 Tatsuya Kitagawa. All rights reserved.
//

#import "ViewController.h"
#import "TKURLRequestFilter.h"

static NSString *kRequestURLString = @"http://httpbin.org/headers";
static NSString *kHostName = @"httpbin.org";

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"TKURLRequestFilter";

    [TKURLRequestFilter registerWithHostName:kHostName filterHandler:^(NSMutableURLRequest *request) {
        [request setValue:@"TKURLRequestFilter is active." forHTTPHeaderField:@"TKURLRequestFilter"];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kRequestURLString]]];
}

@end
