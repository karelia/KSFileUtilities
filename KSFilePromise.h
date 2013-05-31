//
//  KSFilePromise.h
//  Sandvox
//
//  Created by Mike on 19/10/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import <AppKit/AppKit.h>


@class KSFilePromiseDestination;


@interface KSFilePromise : NSObject <NSCopying>
{
  @private
    NSURL                       *_fileURL;
    KSFilePromiseDestination    *_destination;
}

// Loads file promises from the drag info
// Underlying file is automatically deleted when KSFilePromise instance is deallocated
// The document is used to generate a temporary directory to place the files in
// Sudden termination is disabled for as long as any promises are in existence. An unsaved doc also has this effect, but unless saving the doc immediately disposes of the promises, there's some overlap time where KSFilePromise needs to keep sudden termination disabled
// Upon the app quitting, any remaining file promises are automatically cleaned up
// Do NOT attempt to alloc/init KSFilePromise instances yourself
+ (NSArray *)promisesFromDraggingInfo:(id <NSDraggingInfo>)info forDocument:(NSDocument *)doc;

// As above but can be asked to wait for files to arrive
+ (NSArray *)promisesFromDraggingInfo:(id <NSDraggingInfo>)info forDocument:(NSDocument *)doc
		   waitUntilFilesAreReachable:(BOOL)waitTillReachable timeout:(NSTimeInterval)timeout;

+ (BOOL)canReadFilePromiseConformingToTypes:(NSArray *)types fromPasteboard:(NSPasteboard *)pasteboard;

@property(nonatomic, readonly) NSURL *fileURL;

// File promises arrive at the source program's discretion
// This is a crude method to wait until the file at least exists! There's no way to really know when it's actually *complete* though
// If the timeout is reached, returns NO with the most recent reachability error (likely "no such file")
- (BOOL)waitUntilFileIsReachableWithTimeout:(NSTimeInterval)timeout error:(NSError **)error;

@end
