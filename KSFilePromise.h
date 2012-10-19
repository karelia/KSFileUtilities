//
//  KSFilePromise.h
//  Sandvox
//
//  Created by Mike on 19/10/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import <AppKit/AppKit.h>


@class KSFilePromiseDestination;


@interface KSFilePromise : NSObject
{
  @private
    NSURL                       *_fileURL;
    KSFilePromiseDestination    *_destination;
}

// Loads file promises from the drag info
// Underlying file is automatically deleted when KSFilePromise instance is deallocated
// The document is used to generate a temporary directory to place the files in
// Do NOT attempt to alloc/init KSFilePromise instances yourself
+ (NSArray *)promisesFromDraggingInfo:(id <NSDraggingInfo>)info forDocument:(NSDocument *)doc;

@property(nonatomic, readonly) NSURL *fileURL;

@end
