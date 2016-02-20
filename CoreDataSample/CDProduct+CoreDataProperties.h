//
//  CDProduct+CoreDataProperties.h
//  CoreDataSample
//
//  Created by Sergey Zalozniy on 01/02/16.
//  Copyright © 2016 GeekHub. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDProduct.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDProduct (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSDecimalNumber *price;
@property (nullable, nonatomic, retain) NSDecimalNumber *actualPrice;
@property (nullable, nonatomic, retain) NSNumber *complete;
@property (nullable, nonatomic, retain) NSManagedObject *basket;
@property (nonatomic) NSInteger amount;

@end

NS_ASSUME_NONNULL_END
