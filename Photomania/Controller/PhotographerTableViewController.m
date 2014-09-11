//
//  PhotographerTableViewController.m
//  Photomania
//
//  Created by Neo Lee on 8/31/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "PhotographerTableViewController.h"
#import "Photographer+Create.h"
#import "PhotoDatabaseAvailability.h"
#import "PhotosByPhotographerTableViewController.h"
#import "PhotosByPhotographerMapViewController.h"
#import "PhotosByPhotographerImageViewController.h"

@implementation PhotographerTableViewController

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotificationName
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[PhotoDatabaseAvailabilityContextName];
                                                  }];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_NAME_PHOTOGRAPHER];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:_managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Photographer Cell"];
    
    Photographer *photographer = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photographer.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos", photographer.photos.count];
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareViewController:(id)vc forSegue:(NSString *)segueIdentifier fromIndexPath:(NSIndexPath *)indexPath {
    Photographer *photographer = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([vc isKindOfClass:[PhotosByPhotographerTableViewController class]]) {
        PhotosByPhotographerTableViewController *photosTableViewController = (PhotosByPhotographerTableViewController *)vc;
        photosTableViewController.photographer = photographer;
    }
    else if ([vc isKindOfClass:[PhotosByPhotographerMapViewController class]]) {
        PhotosByPhotographerMapViewController *photosMapViewController = (PhotosByPhotographerMapViewController *)vc;
        photosMapViewController.photographer = photographer;
    }
    else if ([vc isKindOfClass:[PhotosByPhotographerImageViewController class]]) {
        PhotosByPhotographerImageViewController *imageViewController = (PhotosByPhotographerImageViewController *)vc;
        imageViewController.photographer = photographer;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id detail = [self.splitViewController.viewControllers lastObject];
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    
    [self prepareViewController:detail forSegue:nil fromIndexPath:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = nil;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [[self tableView] indexPathForCell:sender];
    }

    [self prepareViewController:segue.destinationViewController forSegue:segue.identifier fromIndexPath:indexPath];
}

@end
