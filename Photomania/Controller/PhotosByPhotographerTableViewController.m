//
//  PhotosByPhotographerTableViewController.m
//  Photomania
//
//  Created by Neo Lee on 9/3/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "PhotosByPhotographerTableViewController.h"
#import "Photo+Flickr.h"

@implementation PhotosByPhotographerTableViewController

- (void)setPhotographer:(Photographer *)photographer {
    _photographer = photographer;
    
    self.title = photographer.name;
    [self setupFetchResultController];
}

- (void)setupFetchResultController {
    NSManagedObjectContext *context = self.photographer.managedObjectContext;
    
    if (context) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_NAME_PHOTO];
        request.predicate = [NSPredicate predicateWithFormat:@"photographer = %@", self.photographer];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    }
    else {
        self.fetchedResultsController = nil;
    }
}

@end
