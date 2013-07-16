//
//  KSFilePromise.m
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

#import "KSFilePromise.h"

#import "KSUniformType.h"


@interface KSFilePromiseDestination : NSObject
{
  @private
    NSURL   *_destinationURL;
}

- (id)initForDocument:(NSDocument *)doc;
@property(nonatomic, readonly) NSURL *destinationURL;

@end


#pragma mark -


@implementation KSFilePromise

#pragma mark Lifecycle

+ (NSArray *)promisesFromDraggingInfo:(id<NSDraggingInfo>)info forDocument:(NSDocument *)doc;
{
    KSFilePromiseDestination *destination = [[KSFilePromiseDestination alloc] initForDocument:doc];
    if (!destination) return nil;
    
    NSArray *names = [info namesOfPromisedFilesDroppedAtDestination:[destination destinationURL]];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[names count]];
    
    for (NSString *aName in names)
    {
        KSFilePromise *promise = [[KSFilePromise alloc] initWithName:aName destination:destination];
        [result addObject:promise];
        [promise release];
    }
    
    [destination release];
    
    return result;
}

+ (NSArray *)promisesFromDraggingInfo:(id <NSDraggingInfo>)info forDocument:(NSDocument *)doc
		   waitUntilFilesAreReachable:(BOOL)waitTillReachable timeout:(NSTimeInterval)timeout;
{
	NSArray *result = [self promisesFromDraggingInfo:info forDocument:doc];
	
	if (waitTillReachable)
	{
		for (KSFilePromise *aPromise in result)
		{
			[aPromise waitUntilFileIsReachableWithTimeout:timeout error:NULL];
		}
	}
	
	return result;
}

- (id)initWithName:(NSString *)name destination:(KSFilePromiseDestination *)destination;
{
    NSParameterAssert([name length] > 0);
    NSParameterAssert(destination);
    
    if (self = [self init])
    {
        _fileURL = [[[destination destinationURL] URLByAppendingPathComponent:name] copy];
        _destination = [destination retain];    // when last promise for this destination is dealloced, so will the destination be
    }
    
    return self;
}

- (void)dealloc;
{
    // Delete underlying file
    [[self class] tryToDeleteFilePromiseURL:[self fileURL] destination:_destination retryInterval:2];
    
    [_fileURL release];
    [_destination release]; // if we were last reference to it, the directory is automatically deleted
    
    [super dealloc];
}

+ (BOOL)tryToDeleteFilePromiseURL:(NSURL *)url destination:(KSFilePromiseDestination *)destination retryInterval:(int64_t)delayInSeconds;
{    
    NSError *error;
    BOOL result = [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
	
	if (!result)
    {
        NSLog(@"File promise deletion failed: %@", error);
        NSLog(@"Maybe the file hasn't arrived yet, or will become removable soon. Retrying later");
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            BOOL retryResult = [self tryToDeleteFilePromiseURL:url
												   destination:destination
												 retryInterval:(2 * delayInSeconds)];    // keep extending to minimise interruptions
			
			if (retryResult) NSLog(@"Retried deletion of file promise succeded: %@", [url path]);
        });
    }
	
	return result;
}

#pragma mark Pasteboard Introspection

+ (BOOL)canReadFilePromiseConformingToTypes:(NSArray *)types fromPasteboard:(NSPasteboard *)pasteboard;
{
    if ([pasteboard canReadItemWithDataConformingToTypes:[NSArray arrayWithObject:(NSString *)kPasteboardTypeFilePromiseContent]])
    {
        for (NSPasteboardItem *anItem in [pasteboard pasteboardItems])
        {
            NSString *type = [anItem stringForType:(NSString *)kPasteboardTypeFilePromiseContent];
            if ([KSUniformType type:type conformsToOneOfTypes:types])
            {
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark Properties

@synthesize fileURL = _fileURL;

#pragma mark Waiting for File Existance

- (BOOL)waitUntilFileIsReachableWithTimeout:(NSTimeInterval)timeout error:(NSError **)error;
{
	NSURL *url = self.fileURL;
	NSTimeInterval start = [NSProcessInfo processInfo].systemUptime;
	
	BOOL result;
	while (!(result = [url checkResourceIsReachableAndReturnError:error]))
	{
		if ([NSProcessInfo processInfo].systemUptime - start > timeout) break;
		[NSThread sleepForTimeInterval:0.1f];	// yes it's horriffic. Think of something better before you judge me
	}
	
	return result;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone;
{
    // Immutable
    return [self retain];
}

@end


#pragma mark -


@implementation KSFilePromiseDestination

- (id)initForDocument:(NSDocument *)doc;
{
    if (self = [self init])
    {
        NSURL *docURL = [doc fileURL];
        if (!docURL) docURL = [doc autosavedContentsFileURL];
        
        NSError *error;
        if (!docURL)
        {
            // For completely unsaved docs, chances are they'll be going into NSAutosavedInformationDirectory next
            docURL = [[NSFileManager defaultManager] URLForDirectory:NSAutosavedInformationDirectory
                                                            inDomain:NSUserDomainMask
                                                   appropriateForURL:nil
                                                              create:NO
                                                               error:&error];
            
            if (!docURL)
            {
                NSLog(@"Failed to retrieve autosave directory's lcoation: %@", error);
                docURL = [NSURL fileURLWithPath:NSHomeDirectory() isDirectory:YES];
            }
        }
        
        _destinationURL = [[NSFileManager defaultManager] URLForDirectory:NSItemReplacementDirectory
                                                                 inDomain:NSUserDomainMask
                                                        appropriateForURL:docURL
                                                                   create:YES
                                                                    error:&error];
        
        if (_destinationURL)
        {
            _destinationURL = [_destinationURL copy];
            [[NSProcessInfo processInfo] disableSuddenTermination];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(appWillTerminate:)
                                                         name:NSApplicationWillTerminateNotification
                                                       object:NSApp];
        }
        else
        {
            NSLog(@"Failed to create temp directory for file promises: %@", error);
        }
    }
    
    return self;
}

- (void)close;
{
    if ([self destinationURL])
    {
        // Cleanup the directory
        NSFileManager *manager = [[NSFileManager alloc] init];
        
        NSError *error;
        if (![manager removeItemAtURL:[self destinationURL] error:&error])
        {
            NSLog(@"File promise temp directory deletion failed: %@", error);
        }
        
        [manager release];
        [[NSProcessInfo processInfo] enableSuddenTermination];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationWillTerminateNotification object:NSApp];
        [_destinationURL release]; _destinationURL = nil;
    }
}

- (void)dealloc;
{
    [self close];
    [super dealloc];
}

@synthesize destinationURL = _destinationURL;

- (void)appWillTerminate:(NSNotification *)notification;
{
    [self close];
}

@end
