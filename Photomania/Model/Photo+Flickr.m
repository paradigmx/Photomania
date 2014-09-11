//
//  Photo+Flickr.m
//  Photomania
//
//  Created by Neo Lee on 8/31/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+Create.h"

@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoInfo inManagedObjectContext:(NSManagedObjectContext *)context {
	Photo *photo = nil;
    
    NSString *uniqueID = photoInfo[FLICKR_PHOTO_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_NAME_PHOTO];
    request.predicate = [NSPredicate predicateWithFormat:@"uniqueID = %@", uniqueID];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if (!result || error || result.count > 1) {
        // Error handling
    }
    else if (result.count) {
        photo = [result firstObject];
    }
    else {
        photo = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME_PHOTO inManagedObjectContext:context];
        photo.uniqueID = uniqueID;
        photo.title = [photoInfo valueForKeyPath:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoInfo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.imageURL = [[FlickrFetcher URLforPhoto:photoInfo format:FlickrPhotoFormatLarge] absoluteString];
        photo.latitude = @([photoInfo[FLICKR_LATITUDE] doubleValue]);
        photo.longitude = @([photoInfo[FLICKR_LONGITUDE] doubleValue]);
        photo.thumbnailURL = [[FlickrFetcher URLforPhoto:photoInfo format:FlickrPhotoFormatSquare] absoluteString];
        
        NSString *photographerName = [photoInfo valueForKeyPath:FLICKR_PHOTO_OWNER];
        photo.photographer = [Photographer photographerWithName:photographerName inManagedObjectContext:context];
    }
    
    return photo;
}

+ (void)insertPhotosFromFlickrArray:(NSArray *)photos inManagedObjectContext:(NSManagedObjectContext *)context {
	for (NSDictionary *photo in photos) {
        [self photoWithFlickrInfo:photo inManagedObjectContext:context];
    }
}


@end
