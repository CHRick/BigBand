//
//  ViewController.m
//  BigBand
//
//  Created by huiwenjiaoyu on 15/12/4.
//  Copyright © 2015年 Rick. All rights reserved.
//

#import "ViewController.h"
#import "GDataXMLNode.h"
#import "BigBand.h"
#import "DataManager.h"


@interface ViewController ()<UIWebViewDelegate>


@end

@implementation ViewController


- (UIWebView *)webView
{
    if (_webView == nil) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.frame];

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [_webView loadRequest:[NSURLRequest requestWithURL:self.url]];
        });
        _webView.delegate = self;
        [self.view addSubview:_webView];
    }
    return _webView;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self webView];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    CGFloat hight = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    
    self.webView.frame = CGRectMake(0, 0, hight, width);
    
    
}



@end
