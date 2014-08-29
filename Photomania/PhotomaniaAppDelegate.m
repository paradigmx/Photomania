//
//  PhotomaniaAppDelegate.m
//  Photomania
//
//  Created by Neo on 8/28/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "PhotomaniaAppDelegate.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "PhotoDatabaseAvailability.h"

@interface PhotomaniaAppDelegate () <NSURLSessionDownloadDelegate>
@property (strong, nonatomic) NSManagedObjectContext *photoDatabaseContext;
@property (strong, nonatomic) NSURLSession *flickrDownloadSession;
@property (strong, nonatomic) NSTimer *flickrForegroundFetchTimer;
@end

@implementation PhotomaniaAppDelegate

#define DATABSE_NAME @"Photomania"
#define FLICKR_FETCH @"Fetch Task for Just Posted Photos"
#define FOREGROUND_FLICKR_FETCH_INTERVAL (20*60)
#define BACKGROUND_FLICKR_FETCH_TIMEOUT (10)

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Database initialization w/ UIManagedDocument

- (void)createDatabase {
    if (!self.database) {
        NSURL *url = [self applicationDocumentsDirectory];
        url = [url URLByAppendingPathComponent:DATABSE_NAME];
        self.database = [[UIManagedDocument alloc] initWithFileURL:url];
    }
}

- (void)setDatabase:(UIManagedDocument *)database {
    if (_database != database) {
        _database = database;
    }

    [self useDatabase];
}

- (void)useDatabase {
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.database.fileURL path]]) {
        [self.database saveToURL:self.database.fileURL
                forSaveOperation:UIDocumentSaveForCreating
               completionHandler:^(BOOL success) {
                   self.photoDatabaseContext = self.database.managedObjectContext;
               }];
    } else if (self.database.documentState == UIDocumentStateClosed) {
        [self.database openWithCompletionHandler:^(BOOL success) {
            self.photoDatabaseContext = self.database.managedObjectContext;
        }];
    } else if (self.database.documentState == UIDocumentStateNormal) {
        // No need to do anything here
    }
}

- (void)setPhotoDatabaseContext:(NSManagedObjectContext *)photoDatabaseContext {
    _photoDatabaseContext = photoDatabaseContext;

    [self.flickrForegroundFetchTimer invalidate];
    self.flickrForegroundFetchTimer = nil;
    if (self.photoDatabaseContext) {
        self.flickrForegroundFetchTimer = [NSTimer scheduledTimerWithTimeInterval:FOREGROUND_FLICKR_FETCH_INTERVAL
                                                                           target:self
                                                                         selector:@selector(startFlickrFetch:) userInfo:nil repeats:YES];
    }

    NSDictionary *userInfo = self.photoDatabaseContext ? @{ PhotoDatabaseAvailabilityContextName: self.photoDatabaseContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotificationName
                                                        object:self
                                                      userInfo:userInfo];
}

#pragma mark - Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    [self createDatabase];
    [self startFlickrFetch];

    return YES;
}

#pragma mark - Flickr Fetching

- (void)startFlickrFetch:(NSTimer *)timer {
    [self startFlickrFetch];
}

- (void)startFlickrFetch {
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (![downloadTasks count]) {
            NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription = FLICKR_FETCH;
            [task resume];
        } else {
            for (NSURLSessionDownloadTask *task in downloadTasks) [task resume];
        }
    }];
}

- (NSURLSession *)flickrDownloadSession {
    if (!_flickrDownloadSession) {
        static dispatch_once_t onceToken; // dispatch_once ensures that the block will only ever get executed once per application launch
        dispatch_once(&onceToken, ^{
            // Notice the configuration here is "backgroundSessionConfiguration:"
            // We will (eventually) get the results even if we are not the foreground application
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:FLICKR_FETCH];
            _flickrDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig
                                                                   delegate:self    // MUST have a delegate for background configurations
                                                              delegateQueue:nil];   // nil means "a random, non-main-queue queue"
        });
    }

    return _flickrDownloadSession;
}

#pragma mark - URL session download delegate

- (NSArray *)flickrPhotosAtURL:(NSURL *)url {
    NSDictionary *flickrPropertyList;
    NSData *flickrJSONData = [NSData dataWithContentsOfURL:url];
    if (flickrJSONData) {
        flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData
                                                             options:0
                                                               error:NULL];
    }
    return [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
}

- (void)loadFlickrPhotosFromLocalURL:(NSURL *)localFile intoContext:(NSManagedObjectContext *)context andThenExecuteBlock:(void(^)())done {
    if (context) {
        NSArray *photos = [self flickrPhotosAtURL:localFile];
        [context performBlock:^{
            [Photo insertPhotosFromFlickrArray:photos intoManagedObjectContext:context];
            if (done) done();
        }];
    } else {
        if (done) done();
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)localFile {
    // We shouldn't assume we're the only downloading going on ...
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {
        // ... but if this is the Flickr fetching, then process the returned data
        [self loadFlickrPhotosFromLocalURL:localFile
                               intoContext:self.photoDatabaseContext
                       andThenExecuteBlock:nil];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    // We don't support resuming an interrupted download task
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    // We don't report the progress of a download in our UI, but this is a cool method to do that with
}

// Optional, but we should definitely catch errors here
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error && (session == self.flickrDownloadSession)) {
        NSLog(@"Flickr background download session failed: %@", error.localizedDescription);
    }
}

#pragma mark - Background fetch

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (self.photoDatabaseContext) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.allowsCellularAccess = NO;
        sessionConfig.timeoutIntervalForRequest = BACKGROUND_FLICKR_FETCH_TIMEOUT; // be a good background citizen
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                                                            if (error) {
                                                                NSLog(@"Flickr background fetch failed: %@", error.localizedDescription);
                                                                completionHandler(UIBackgroundFetchResultNoData);
                                                            } else {
                                                                [self loadFlickrPhotosFromLocalURL:localFile
                                                                                       intoContext:self.photoDatabaseContext
                                                                               andThenExecuteBlock:^{
                                                                                   completionHandler(UIBackgroundFetchResultNewData);
                                                                               }
                                                                 ];
                                                            }
                                                        }];
        [task resume];
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

@end
