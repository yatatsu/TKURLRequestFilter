# TKURLRequestFilter

TKURLRequestFilter is subclass of ``NSURLProtocol`` for filtering http request simply.

## Usage

```
[TKURLRequestFilter registerWithHostName:@"httpbin.org" filterHandler:^(NSMutableURLRequest *request) {
        [request setValue:@"TKURLRequestFilter is active." forHTTPHeaderField:@"TKURLRequestFilter"];
}];
```

For example in UIWebView. 

```
[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://httpbin.org/headers"]]];
```

