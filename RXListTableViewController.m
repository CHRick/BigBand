//
//  RXListTableViewController.m
//  BigBand
//
//  Created by huiwenjiaoyu on 15/12/4.
//  Copyright © 2015年 Rick. All rights reserved.
//

#import "RXListTableViewController.h"
#import <CoreData/CoreData.h>
#import "DataManager.h"
#import "BigBand.h"
#import "GDataXMLNode.h"
#import "ViewController.h"


@interface RXListTableViewController ()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchController;
@property (nonatomic, strong) NSMutableArray *urls;
@property (nonatomic, copy) NSString *tragetName;
@property (nonatomic, assign) NSInteger nextSeason;

@end

@implementation RXListTableViewController

- (NSMutableArray *)urls
{
    if (_urls == nil) {
        _urls = [NSMutableArray array];
    }
    
    return _urls;
}

- (NSFetchedResultsController *)fetchController
{
    if (_fetchController == nil) {
        
        DataManager *manager = [DataManager shareManager];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"BigBand"];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"season" ascending:NO];
        request.sortDescriptors = @[sort];
        _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:manager.managedObjectContext sectionNameKeyPath:@"season" cacheName:nil];
        _fetchController.delegate = self;
        [_fetchController performFetch:nil];
    }
    return _fetchController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(requestData)];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"nextSeason"] integerValue] == 0) {
        
        self.nextSeason = 6;
    }else{
        self.nextSeason = [[[NSUserDefaults standardUserDefaults] objectForKey:@"nextSeason"] integerValue];
    }
}

- (void)setNextSeason:(NSInteger)nextSeason
{
    if (_nextSeason != nextSeason) {
        _nextSeason = nextSeason;
        [[NSUserDefaults standardUserDefaults] setObject:@(_nextSeason) forKey:@"nextSeason"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - 请求网络数据

- (void)requestData
{
    NSLog(@"nextSeason%ld",self.nextSeason);
    self.tragetName = [NSString stringWithFormat:@"\n生活大爆炸 The Big Bang Theory S09E%02ld 720p 圣城家园SCG字幕组",self.nextSeason];
    
    NSURL *url = [NSURL URLWithString:@"http://www.ttmeiju.com/meiju/The.Big.Bang.Theory.html"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
        
        GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithHTMLData:data encoding:nil error:nil];
        NSString *xpath = @"//tr[@class='Scontent']";
        
        NSArray *array = [document nodesForXPath:xpath error:nil];
        
        for (GDataXMLElement *ele in array) {
            
            for (GDataXMLElement *child in ele.children) {
                
                if ([[child stringValue] isEqual:self.tragetName]) {
                    
                    [self.urls addObject:ele];
                }
            }
        }
        [self targetEle];
    }];
    
    [task resume];
}

- (void)targetEle
{
    GDataXMLDocument *subDocument = [[GDataXMLDocument alloc] initWithRootElement:self.urls.lastObject];
    
    NSString *subPath = @"//a";
    NSArray *subArray = [subDocument nodesForXPath:subPath error:nil];
    for (GDataXMLElement *ele in subArray) {
        
        if ([[[ele attributeForName:@"title"] stringValue] isEqualToString:@"百度云盘下载"]) {
            
            NSLog(@"%@",[[ele attributeForName:@"href"] stringValue]);
            
            for (BigBand *item in self.fetchController.fetchedObjects) {
                if ([item.url isEqualToString:[[ele attributeForName:@"href"] stringValue]]) {
                    return;
                }
            }
            
            DataManager *manager = [DataManager shareManager];
            BigBand *bigBand = [NSEntityDescription insertNewObjectForEntityForName:@"BigBand" inManagedObjectContext:manager.managedObjectContext];
            bigBand.name = [NSString stringWithFormat:@"The Big Bang Theory S09E%02ld",self.nextSeason];
            bigBand.url = [[ele attributeForName:@"href"] stringValue];
            bigBand.season = @(self.nextSeason);
            self.nextSeason = self.nextSeason + 1;
            [manager saveContext];
        }
    }
}

- (NSArray *)fetchData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BigBand" inManagedObjectContext:[DataManager shareManager].managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"season=%ld", self.nextSeason];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"season"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[DataManager shareManager].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        
        
    }
    return fetchedObjects;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.fetchController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSArray *array = self.fetchController.sections;
    
    return [array[section] numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    BigBand *bigBand = [self.fetchController objectAtIndexPath:indexPath];
    cell.textLabel.text = bigBand.name;
    
    return cell;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DataManager *manager = [DataManager shareManager];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        BigBand *bigBand = [self.fetchController objectAtIndexPath:indexPath];
        [manager.managedObjectContext deleteObject:bigBand];
        [manager saveContext];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BigBand *bigBand = [self.fetchController objectAtIndexPath:indexPath];
    ViewController *vc = [[ViewController alloc] init];
    vc.url = [NSURL URLWithString:bigBand.url];
    NSLog(@"%@",bigBand.url);
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - fetchedResultsControll

/*
 
 NSFetchedResultsChangeInsert = 1,
	NSFetchedResultsChangeDelete = 2,
	NSFetchedResultsChangeMove = 3,
	NSFetchedResultsChangeUpdate = 4
 
 */

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:sectionIndex];
    
    switch (type) {
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:set withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:set withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}



@end
