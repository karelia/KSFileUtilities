//
//  KSFilePromise.m
//  Sandvox
//
//  Created by Mike on 19/10/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import "KSFilePromise.h"


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
    NSFileManager *manager = [[NSFileManager alloc] init];
    
    NSError *error;
    if (![manager removeItemAtURL:[self fileURL] error:&error])
    {
        NSLog(@"File promise deletion failed: %@", error);
    }
    
    [manager release];
    [_fileURL release];
    
    [_destination release]; // if we were last reference to it, the directory is automatically deleted
    
    [super dealloc];
}

@synthesize fileURL = _fileURL;

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
        if (!docURL) docURL = [NSURL fileURLWithPath:@"/" isDirectory:YES]; // FIXME: Root dir seems an odd choice for fallback
        
        NSError *error;
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
