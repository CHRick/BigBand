//
//  BigBand+CoreDataProperties.h
//  BigBand
//
//  Created by huiwenjiaoyu on 15/12/9.
//  Copyright © 2015年 Rick. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "BigBand.h"

NS_ASSUME_NONNULL_BEGIN

@interface BigBand (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSNumber *season;

@end

NS_ASSUME_NONNULL_END
