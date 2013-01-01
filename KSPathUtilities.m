//
//  KSPathUtilities.m
//
//  Copyright (c) 2005-2012 Dan Wood, Mike Abdullah and Karelia Software
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "KSPathUtilities.h"


@interface KSIncrementedPath : NSString
{
  @private
    NSString    *_storage;
    NSString    *_basePath;
    NSUInteger  _suffix;
}

- (id)initWithBasePath:(NSString *)basePath suffix:(NSUInteger)suffix;
@end


#pragma mark -


@implementation NSString (KSPathUtilities)

#pragma mark Making Paths

+ (NSString *)ks_stringWithPath:(NSString *)path relativeToDirectory:(NSString *)directory;
{
    NSParameterAssert(path);
    
    if (!directory || [path isAbsolutePath]) return path;
    
    NSString *result = [directory stringByAppendingPathComponent:path];
    return result;
}

#pragma mark Path Suffix

- (NSString *)ks_stringWithPathSuffix:(NSString *)aString;
{
    NSString *extension = [self pathExtension];
    if ([extension length])
    {
        NSString *result = [[[self
                              stringByDeletingPathExtension]
                             stringByAppendingString:aString]
                            stringByAppendingPathExtension:extension];
        return result;
    }
    else
    {
        // It's possible that the extension-less path ends with a slash. They need to be stripped
        return [[self ks_standardizedPOSIXPath] stringByAppendingString:aString];
    }
}

- (NSString *)ks_stringByIncrementingPath;
{
    return [[[KSIncrementedPath alloc] initWithBasePath:self suffix:2] autorelease];
}

#pragma mark Comparing Paths

- (BOOL)ks_isEqualToPath:(NSString *)aPath;
{
    NSString *myPath = [self stringByStandardizingPath];
    aPath = [aPath stringByStandardizingPath];
    
    BOOL result = ([myPath caseInsensitiveCompare:aPath] == NSOrderedSame);
    return result;
}

/*  We can somewhat cheat by giving each path a trailing slash and then do simple string comparison.
 That way we ensure that we don't have something like ABCDEFGH being considered a subpath of ABCD
 But ABCD/EFGH will be.
 */
- (BOOL)ks_isSubpathOfPath:(NSString *)aPath
{
    NSParameterAssert(aPath);  // karelia case #115844
    
    
	NSString *adjustedMePath = self;
	if (![adjustedMePath isEqualToString:@"/"])
	{
		adjustedMePath = [adjustedMePath stringByAppendingString:@"/"];
	}
	
	NSString *adjustedOtherPath = aPath;
	if (![adjustedOtherPath hasSuffix:@"/"])
	{
		adjustedOtherPath = [adjustedOtherPath stringByAppendingString:@"/"];
	}
    
    // Used to -hasPrefix:, but really need to do it case insensitively
    NSRange result = [adjustedMePath rangeOfString:adjustedOtherPath
                                           options:(NSAnchoredSearch | NSCaseInsensitiveSearch)];
    
    return (result.location == 0);
}


- (NSString *)ks_pathRelativeToDirectory:(NSString *)dirPath
{
    if ([dirPath isAbsolutePath])
    {
        if (![self isAbsolutePath]) return self;    // job's already done for us!
    }
    else
    {
        // An absolute path relative to a relative path is always going to be self
        if ([self isAbsolutePath]) return self;
        
        // But comparing two relative paths is a bit of an edge case. Internally, pretend they're absolute
        dirPath = (dirPath ? [@"/" stringByAppendingString:dirPath] : @"/");
        return [[@"/" stringByAppendingString:self] ks_pathRelativeToDirectory:dirPath];
    }
    
    
    // Easy way out
    if ([self isEqualToString:dirPath]) return @".";
    
    
    // Determine the common ancestor directory containing both paths. String comparison is a naive first pass...
    NSString *commonDir = [self commonPrefixWithString:dirPath options:NSLiteralSearch];
	if ([commonDir isEqualToString:@""]) return self;
	
    // ...as what the paths have in common could be two similar folder names
    // e.g. /foo/barnicle and /foo/bart/baz
    // If so, wind back to the nearest slash
    if (![commonDir hasSuffix:@"/"])
    {
        if ([self length] > [commonDir length] &&
        [self characterAtIndex:[commonDir length]] != '/')
        {
            NSUInteger separatorLocation = [commonDir rangeOfString:@"/" options:NSBackwardsSearch].location;
            if (separatorLocation == NSNotFound) separatorLocation = 0;
            commonDir = [commonDir substringToIndex:separatorLocation];
        }
        else if ([dirPath length] > [commonDir length] &&
                 [dirPath characterAtIndex:[commonDir length]] != '/')
        {
            NSUInteger separatorLocation = [commonDir rangeOfString:@"/" options:NSBackwardsSearch].location;
            if (separatorLocation == NSNotFound) separatorLocation = 0;
            commonDir = [commonDir substringToIndex:separatorLocation];
        }
    }
    
    
    NSMutableString *result = [NSMutableString stringWithCapacity:
                        [self length] + [dirPath length] - 2*[commonDir length]];
    
    
    // How do you get from the directory path, to commonDir?
    NSRange searchRange; searchRange.location = [commonDir length]; searchRange.length = [dirPath length] - searchRange.location;
    while (searchRange.length > 0)
    {
        NSRange slashRange = [dirPath rangeOfString:@"/" options:NSLiteralSearch range:searchRange];
        if (slashRange.location == NSNotFound) slashRange.location = NSMaxRange(searchRange);   // for end of string
        NSRange componentRange = NSMakeRange(searchRange.location, slashRange.location - searchRange.location);
        
        if (componentRange.length > 0)
        {
            // Ignore components which just specify current directory
            if (componentRange.length > 1 || [dirPath compare:@"." options:NSLiteralSearch range:componentRange] != NSOrderedSame)
            {
                if (componentRange.length == 2)
                {
                    NSAssert([dirPath compare:@".." options:NSLiteralSearch range:componentRange] != NSOrderedSame, @".. unsupported");
                }
                
                if ([result length]) [result appendString:@"/"];
                [result appendString:@".."];
            }
        }
        
        searchRange = NSMakeRange(NSMaxRange(slashRange), NSMaxRange(searchRange) - NSMaxRange(slashRange));
    }
    
    
    // And then navigating from commonDir, to self, is mostly a simple append
	NSString *pathRelativeToCommonDir = [self substringFromIndex:[commonDir length]];
    
    // But ignore leading slash(es) since they cause relative path to be reported as absolute
    while ([pathRelativeToCommonDir hasPrefix:@"/"])
    {
        pathRelativeToCommonDir = [pathRelativeToCommonDir substringFromIndex:1];
    }
    
    if ([pathRelativeToCommonDir length])
    {
        if ([result length]) [result appendString:@"/"];
        [result appendString:pathRelativeToCommonDir];
    }
	
    
    // Were the paths found to be equal?
	if ([result length] == 0)
    {
        [result appendString:@"."];
        [result appendString:[self substringFromIndex:[commonDir length]]]; // match original's oddities
    }
    
	
	return result;
}

- (void)ks_enumeratePathComponentsInRange:(NSRange)searchRange usingBlock:(void (^)(NSString *component, NSRange range, BOOL *stop))block;
{
    // Report absolute path's first component specially
    if (searchRange.location == 0 && [self isAbsolutePath])
    {
        NSRange range = NSMakeRange(0, 1);
        BOOL stop = NO;
        block(@"/", range, &stop);
        if (stop) return;
    }
    
    do
    {
        NSRange slashRange = [self rangeOfString:@"/" options:NSLiteralSearch range:searchRange];
        
        if (slashRange.location != searchRange.location)
        {
            NSRange range = (slashRange.location == NSNotFound ?
                             searchRange :
                             NSMakeRange(searchRange.location, slashRange.location - searchRange.location));
            
            if (range.length == 0) return;
            
            NSString *component = [self substringWithRange:range];
            BOOL stop = NO;
            
            block(component, range, &stop);
            if (stop) return;
            
            // bump up slashRange so adjusting searchRange has correct effect
            slashRange.length += range.length;
        }
        
        searchRange.location += slashRange.length; searchRange.length -= slashRange.length;
    }
    while (searchRange.length);
}

#pragma mark POSIX

/*  Trailing slashes are insignificant under the POSIX standard. If the receiver has a trailing
 *  slash, a new string is returned with the slash removed.
 */
- (NSString *)ks_standardizedPOSIXPath
{
    NSString *result = self;
    
    while ([result length] > 1 && [result hasSuffix:@"/"]) // Stops @"/" being altered
    {
        result = [result substringToIndex:([result length] - 1)];
    }
    
    return result;
}

/*  You should generally use this method when comparing two paths for equality. Unlike -isEqualToString:
 *  it treats any trailing slash as insignificant. NO reference to the local filesystem is used.
 */
- (BOOL)ks_isEqualToPOSIXPath:(NSString *)otherPath
{
    BOOL result = [[self ks_standardizedPOSIXPath] isEqualToString:[otherPath ks_standardizedPOSIXPath]];
    return result;
}

@end


#pragma mark -


@implementation KSIncrementedPath

- (id)initWithBasePath:(NSString *)basePath suffix:(NSUInteger)suffix;
{
    NSParameterAssert(suffix >= 2);
    
    self = [self init];
    
    _basePath = [basePath copy];
    _suffix = suffix;
    _storage = [[basePath ks_stringWithPathSuffix:[NSString stringWithFormat:@"-%lu", (unsigned long) suffix]] copy];
    
    return self;
}

- (void)dealloc;
{
    [_basePath release];
    [_storage release];
    [super dealloc];
}

- (NSString *)ks_stringByIncrementingPath;
{
    return [[[[self class] alloc] initWithBasePath:_basePath suffix:(_suffix + 1)] autorelease];
}

#pragma mark NSString Primitives

- (NSUInteger)length; { return [_storage length]; }
- (unichar)characterAtIndex:(NSUInteger)index; { return [_storage characterAtIndex:index]; }

@end

