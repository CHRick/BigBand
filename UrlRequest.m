//
//  UrlRequest.m
//  BigBand
//
//  Created by huiwenjiaoyu on 15/12/8.
//  Copyright © 2015年 Rick. All rights reserved.
//

#import "UrlRequest.h"

@implementation UrlRequest

- (NSMutableArray *)urls
{
    if (_urls == nil) {
        _urls = [NSMutableArray array];
    }
    return _urls;
}

- (void)requestForData
{
    NSURL *url = [NSURL URLWithString:@"http://www.ttmeiju.com/meiju/The.Big.Bang.Theory.html"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithHTMLData:data encoding:nil error:nil];
        NSString *xpath = @"//tr[@class='Scontent']";
        
        NSArray *array = [document nodesForXPath:xpath error:nil];
        
        for (GDataXMLElement *ele in array) {
            
            for (GDataXMLElement *child in ele.children) {
                
                if ([[child stringValue] isEqual:@"\n生活大爆炸 The Big Bang Theory S09E09 720p 圣城家园SCG字幕组"]) {
                    
                    [self.urls addObject:ele];
                }
            }
        }
        [self targetUrls];
    }];
    
    [task resume];
}

- (void)targetUrls
{
    GDataXMLDocument *subDocument = [[GDataXMLDocument alloc] initWithRootElement:self.urls.lastObject];
    
    NSString *subPath = @"//a";
    NSArray *subArray = [subDocument nodesForXPath:subPath error:nil];
    for (GDataXMLElement *ele in subArray) {
        
        if ([[[ele attributeForName:@"title"] stringValue] isEqualToString:@"百度云盘下载"]) {
            
            [self.urls addObject:[[ele attributeForName:@"href"] stringValue]];
            NSLog(@"%@",[[ele attributeForName:@"href"] stringValue]);
        }
    }
}

@end
