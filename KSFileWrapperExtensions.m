//
//  KSFileWrapperExtensions.m
//
//  Created by Mike Abdullah
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

#import "KSFileWrapperExtensions.h"


@implementation NSFileWrapper (KSFileWrapperExtensions)

#pragma mark Directories

- (NSString *)addFileWrapper:(NSFileWrapper *)wrapper subdirectory:(NSString *)subpath;
{
    // Create any directories required by the subpath
    NSArray *components = [subpath pathComponents];
    NSFileWrapper *parentWrapper = self;
    
    NSUInteger i, count = [components count];
    for (i = 0; i < count; i++)
    {
        NSString *aComponent = [components objectAtIndex:i];
        NSFileWrapper *aWrapper = [[parentWrapper fileWrappers] objectForKey:aComponent];
        if (!aWrapper)
        {
            aWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:@{}];
            [aWrapper setPreferredFilename:aComponent];
            [parentWrapper addFileWrapper:aWrapper];
            
#if ! __has_feature(objc_arc)
            [aWrapper release];
#endif
        }
        
        parentWrapper = aWrapper;
    }
    
    // We finally have a suitable parent to add the wrapper to
    return [parentWrapper addFileWrapper:wrapper];
}

- (void)ks_removeAllVisibleFileWrappers;
{
    // Leopard had a bug where -fileWrappers returns its own backing store, which means it will mutate while enumerating
    NSDictionary *wrappers = [[self fileWrappers] copy];
    
    for (NSString *aFilename in wrappers)
    {
        if (![aFilename hasPrefix:@"."])
        {
            NSFileWrapper *aWrapper = [wrappers objectForKey:aFilename];
            [self removeFileWrapper:aWrapper];
        }
    }
    
    [wrappers release];
}

#pragma mark Symlinks

- (NSFileWrapper *)ks_symbolicLinkDestinationFileWrapper;
{
#if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6
    if (![self respondsToSelector:@selector(symbolicLinkDestinationURL)] ||
        ![NSFileWrapper instancesRespondToSelector:@selector(initWithURL:options:error:)])
    {
        NSFileWrapper *result = [[NSFileWrapper alloc] initWithPath:[self symbolicLinkDestination]];
        return [result autorelease];
    }
#endif
    
    NSFileWrapper *result = [[NSFileWrapper alloc] initWithURL:[self symbolicLinkDestinationURL]
                                                       options:0
                                                         error:NULL];
    return [result autorelease];
}

#pragma mark Writing Files

- (BOOL)ks_writeToURL:(NSURL *)URL options:(NSFileWrapperWritingOptions)options originalParentDirectoryURL:(NSURL *)originalParentDirectory error:(NSError **)outError;
{
    return [self ks_writeToURL:URL options:options originalParentDirectoryURL:originalParentDirectory copyIfLinkingFails:YES error:outError];
}

- (BOOL)ks_writeToURL:(NSURL *)URL options:(NSFileWrapperWritingOptions)options originalParentDirectoryURL:(NSURL *)originalParentDirectory copyIfLinkingFails:(BOOL)fallbackToCopy error:(NSError **)outError;
{
    NSString *filename = [self filename];
    
    // The NSFileWrapper docs state:
    //
    //  The default implementation of this method attempts to avoid unnecessary I/O by writing hard links to regular files instead of actually writing out their contents when the contents have not changed. The child file wrappers must return accurate values when sent the filename method for this to work
    //
    // I'm assuming that to decide if "they've changed", NSFileWrapper is consulting its -matchesContentsOfURL: which looks purely at modification dates
    // If that's all the system cares about then it'll get a false positive should a new wrapper have the same filename as an existing file in the package, and they share the same or similar mod date. Very very rare, but we have a customer for whom it happened
    // Does NSFileWrapper then sacrifice a little possible efficiency by only doing hardlinking if the filenames match too? i.e. that the filename being written to is the same as the source? If so, that would avoid this fasle positive. On the downside it would make adjusting filenames for existing files inside the package impossible to do efficiently, but that's pronbably not a big deal
    // I haven't devised a proper test of NSFileWrapper for this yet; just going to go ahead and do the filename check for now
    
    NSURL *originalURL = ([filename isEqualToString:[URL lastPathComponent]] ? [originalParentDirectory URLByAppendingPathComponent:filename] : nil);
    
    // NSFileWrapper won't create hardlinks when writing an individual file, so we try to do so ourselves when reasonable, for performance reasons
    if ([self isRegularFile])    
    {
        // If the file is already inside a doc, we favour hardlinking for performance
        if ([self matchesContentsOfURL:originalURL])
        {
            // Linking might fail because:
            // - The destination URL already exists
            // - It's an external filesystem which doesn't support hardlinks. #190275
            // - Attempted to link across filesystems
            //
            // If so, can just fall back to standard writing, which will handle all situations
            BOOL result = [[NSFileManager defaultManager] linkItemAtURL:originalURL toURL:URL error:outError];
            
            if (result || !fallbackToCopy) return result;
        }
    }
    
    // For regular files, asking NSFileWrapper is the final fallback
    // For folders/packages, this will take the fast path of using hardlinks if possible. Unfortunately when taking the slow path, it does so by loading each file into memory. We dump them back out again when releasing the wrapper, but this could definitely be improved
    return [self writeToURL:URL options:options originalContentsURL:originalURL error:outError];
}

@end
