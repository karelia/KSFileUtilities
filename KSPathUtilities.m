//
//  KSPathUtilities.m
//
//  Created by Mike Abdullah based on earlier code by Dan Wood
//  Copyright © 2005 Karelia Software
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

#pragma mark Finding Path Components

- (void)ks_enumeratePathComponentsInRange:(NSRange)range
                                  options:(NSStringEnumerationOptions)opts  // only NSStringEnumerationSubstringNotRequired is supported for now
                               usingBlock:(void (^)(NSString *component, NSRange componentRange, NSRange enclosingRange, BOOL *stop))block;
{
    while (range.length)
    {
        // Seek for next path separator
        NSRange enclosingRange = NSMakeRange(range.location, 0);
        NSRange separatorRange = [self rangeOfString:@"/" options:NSLiteralSearch range:range];
        
        // Separators that don't mark a new component can be more-or-less ignored
        while (separatorRange.location == range.location)
        {
            // Absolute paths are a special case where we have to treat the leading slash as a component
            if (separatorRange.location == 0)
            {
                // Search for immediately following separator, but no more
                separatorRange = NSMakeRange(separatorRange.length, 0); // weird fake, yes
                if (self.length > separatorRange.location && [self characterAtIndex:separatorRange.location] == '/') separatorRange.length = 1;
                break;
            }
            
            range.location += separatorRange.length; range.length -= separatorRange.length;
            if (range.length == 0) return;
            
            enclosingRange.length += separatorRange.length;
            
            separatorRange = [self rangeOfString:@"/" options:NSLiteralSearch range:range];
        }
        
   
        // Now we know where the component lies
        NSRange componentRange = range;
        if (separatorRange.location == NSNotFound)
        {
            range.length = 0;   // so we finish after this iteration
        }
        else
        {
            range = NSMakeRange(NSMaxRange(separatorRange), NSMaxRange(range) - NSMaxRange(separatorRange));
            
            componentRange.length = (separatorRange.location - componentRange.location);
            
            enclosingRange.length += separatorRange.length;
            
            
            // Look for remainder of enclosingRange that immediately follow the component
            separatorRange = [self rangeOfString:@"/" options:NSAnchoredSearch|NSLiteralSearch range:range];
            while (separatorRange.location != NSNotFound)
            {
                enclosingRange.length += separatorRange.length;
                range.location += separatorRange.length; range.length -= separatorRange.length;
                separatorRange = [self rangeOfString:@"/" options:NSAnchoredSearch|NSLiteralSearch range:range];
            }
        }
        
        enclosingRange.length += componentRange.length; // only add now that componentRange.length is correct
        
        BOOL stop = NO;
        block((opts & NSStringEnumerationSubstringNotRequired ? nil : [self substringWithRange:componentRange]),
              componentRange,
              enclosingRange,
              &stop);
        
        if (stop) return;
    }
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
    
    
    // Strip off trailing slashes as they confuse the search
    while ([aPath hasSuffix:@"/"] && ![self hasSuffix:@"/"] && aPath.length > 1)
    {
        aPath = [aPath substringToIndex:aPath.length - 1];
    }
    
    // Used to -hasPrefix:, but really need to do it case insensitively
    NSRange range = [self rangeOfString:aPath
                                options:(NSAnchoredSearch | NSCaseInsensitiveSearch)];
    
    if (range.location != 0) return NO;
    
    // Correct for last component being only a sub*string*
    if (self.length == range.length) return YES;  // shortcut for exact match
    if ([aPath hasSuffix:@"/"]) return YES; // when has a directory termintator, no risk of mismatch
    
    BOOL result = ([self characterAtIndex:range.length] == '/');
    return result;
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
    
    
    // Determine the common ancestor directory containing both paths
    __block NSRange mySearchRange = NSMakeRange(1, [self length] - 1);
    NSMutableString *result = [NSMutableString string];
    
    
    if ([self hasPrefix:dirPath])   // easy win when self is obviously a subpath
    {
        mySearchRange.location = NSMaxRange([self rangeOfString:dirPath options:NSAnchoredSearch]);
        mySearchRange.length = self.length - mySearchRange.location;
    }
    else
    {
        __block NSRange dirSearchRange = NSMakeRange(1, [dirPath length] - 1);
        
        [self ks_enumeratePathComponentsInRange:mySearchRange options:0 usingBlock:^(NSString *myComponent, NSRange myRange, NSRange enclosingRange, BOOL *stopOuter) {
            
            // Does it match the other path?
            [dirPath ks_enumeratePathComponentsInRange:dirSearchRange options:0 usingBlock:^(NSString *dirComponent, NSRange dirRange, NSRange enclosingRange, BOOL *stopInner) {
                
                if ([myComponent compare:dirComponent options:0] == NSOrderedSame)
                {
                    dirSearchRange = NSMakeRange(NSMaxRange(dirRange),
                                                 NSMaxRange(dirSearchRange) - NSMaxRange(dirRange));
                    
                    mySearchRange = NSMakeRange(NSMaxRange(myRange),
                                                NSMaxRange(mySearchRange) - NSMaxRange(myRange));
                }
                else
                {
                    *stopOuter = YES;
                }
                
                *stopInner = YES;
            }];
        }];
        
        
        // How do you get from the directory path, to commonDir?
        [dirPath ks_enumeratePathComponentsInRange:dirSearchRange options:NSStringEnumerationSubstringNotRequired usingBlock:^(NSString *component, NSRange range, NSRange enclosingRange, BOOL *stop) {
            
            // Ignore components which just specify current directory
            if ([dirPath compare:@"." options:NSLiteralSearch range:range] == NSOrderedSame) return;
            
            
            if (range.length == 2) NSAssert([dirPath compare:@".." options:NSLiteralSearch range:range] != NSOrderedSame, @".. unsupported: %@", dirPath);
            
            if ([result length]) [result appendString:@"/"];
            [result appendString:@".."];
        }];
    }
    
    // And then navigating from commonDir, to self, is mostly a simple append
	NSString *pathRelativeToCommonDir = [self substringWithRange:mySearchRange];
    
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
        [result appendString:[self substringWithRange:mySearchRange]]; // match original's oddities
    }
    
	
	return result;
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

