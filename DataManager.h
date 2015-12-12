//
//  DataManager.h
//  BigBand
//
//  Created by huiwenjiaoyu on 15/12/4.
//  Copyright © 2015年 Rick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)shareManager;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
