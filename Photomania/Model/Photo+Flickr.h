//
//  Photo+Flickr.h
//  Photomania
//
//  Created by Neo Lee on 8/31/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "Photo.h"

#define ENTITY_NAME_PHOTO @"Photo"

@interface Photo (Flickr)
+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoInfo inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)insertPhotosFromFlickrArray:(NSArray *)photos inManagedObjectContext:(NSManagedObjectContext *)context;
@end
