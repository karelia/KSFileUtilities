//
//  KSFilePromise.h
//  Sandvox
//
//  Created by Mike Abdullah on 19/10/2012.
//  Copyright © 2012 Karelia Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
