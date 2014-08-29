//
//  Photo+Flickr.m
//  Photomania
//
//  Created by Neo on 8/28/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+Create.h"

@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Photo *photo = nil;

    // TODO: Very bad performance when inserting many photos, try improve it later
    NSString *uniqueID = photoDictionary[FLICKR_PHOTO_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_NAME_PHOTO];
    request.predicate = [NSPredicate predicateWithFormat:@"uniqueID = %@", uniqueID];

    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    if (!matches || error || matches.count > 1) {
        // Error handling
    }
    else if (matches.count) {
        photo = [matches firstObject];
    }
    else {
        photo = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME_PHOTO inManagedObjectContext:context];
        photo.uniqueID = uniqueID;
        photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];

        NSString *photographerName = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
        photo.photographer = [Photographer photographerWithName:photographerName inManagedObjectContext:context];
    }

	return photo;
}

+ (void)loadPhotosFromFlickrArray:(NSArray *)photos intoManagedObjectContext:(NSManagedObjectContext *)context {
	for (NSDictionary *photo in photos) {
        [self photoWithFlickrInfo:photo inManagedObjectContext:context];
    }
}


@end
