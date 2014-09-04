//
//  Photo.h
//  Photomania
//
//  Created by Neo Lee on 8/31/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) Photographer *photographer;

@end
