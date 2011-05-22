//
//  KSPathUtilities.m
//
//  Copyright (c) 2005-2011, Dan Wood, Mike Abdullah and Karelia Software
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


@implementation NSString (KSPathUtilities)

- (BOOL)ks_isEqualToPath:(NSString *)aPath;
{
    NSString *myPath = [self stringByStandardizingPath];
    aPath = [aPath stringByStandardizingPath];
    
    BOOL result = ([myPath caseInsensitiveCompare:aPath] == NSOrderedSame);
    return result;
}

- (NSString *)ks_stringWithPathSuffix:(NSString *)aString;
{
    NSString *result = self;
    
    NSString *extension = [self pathExtension];
    if ([extension length])
    {
        result = [[[self
                    stringByDeletingPathExtension]
                   stringByAppendingString:aString]
                  stringByAppendingPathExtension:extension];
    }
    else
    {
        result = [self stringByAppendingString:aString];
    }
    
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
        return [[@"/" stringByAppendingString:self] ks_pathRelativeToDirectory:[@"/" stringByAppendingString:dirPath]];
    }
    
    
    // Easy way out
    if ([self isEqualToString:dirPath]) return @".";
    
    
    // Our internal workings currently expect dirPath to have a trailing slash, so let's supply that for them
    if (![dirPath hasSuffix:@"/"]) dirPath = [dirPath stringByAppendingString:@"/"];
    
    
	NSString *commonPrefix = [self commonPrefixWithString:dirPath options:NSLiteralSearch];
	// Make sure common prefix ends with a / ... if not, back up to the previous /
	if ([commonPrefix isEqualToString:@""])
	{
		return self;
	}
	if (![commonPrefix hasSuffix:@"/"])
	{
		NSRange whereSlash = [commonPrefix rangeOfString:@"/" options:NSLiteralSearch|NSBackwardsSearch];
		if (NSNotFound == whereSlash.location)
		{
			return self;	// nothing in common, return
		}
		
		// Fix commonPrefix so it ends in /
		commonPrefix = [commonPrefix substringToIndex:NSMaxRange(whereSlash)];
	}
	
	NSString *myDifferingPath = [self substringFromIndex:[commonPrefix length]];
	NSString *otherDifferingPath = [dirPath substringFromIndex:[commonPrefix length]];
	
	NSMutableString *buf = [NSMutableString string];
	NSUInteger i;
	
	// generate hops up from other to the common place
	NSArray *hopsUpArray = [otherDifferingPath pathComponents];
	NSUInteger hopsUp = MAX(0,(NSInteger)[hopsUpArray count] - 1);
	for (i = 0 ; i < hopsUp ; i++ )
	{
		[buf appendString:@"../"];
	}
	
	// the rest is the relative path to me
	[buf appendString:myDifferingPath];
	
	if ([buf isEqualToString:@""])	
	{
		if ([self hasSuffix:@"/"])
		{
			[buf appendString:@"./"];	// if our relative link is to the top, then replace with ./
		}
		else	// link to yourself; give us just the file name
		{
			[buf appendString:[self lastPathComponent]];
		}
	}
	NSString *result = [NSString stringWithString:buf];
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
	if (![adjustedOtherPath isEqualToString:@"/"])
	{
		adjustedOtherPath = [adjustedOtherPath stringByAppendingString:@"/"];
	}
    
    // Used to -hasPrefix:, but really need to do it case insensitively
    NSRange result = [adjustedMePath rangeOfString:adjustedOtherPath
                                           options:(NSAnchoredSearch | NSCaseInsensitiveSearch)];
    
    return (result.location == 0);
}


/*  Trailing slashes are insignificant under the POSIX standard. If the receiver has a trailing
 *  slash, a new string is returned with the slash removed.
 */
- (NSString *)ks_standardizedPOSIXPath
{
    if ([self length] > 1 && [self hasSuffix:@"/"]) // Stops @"/" being altered
    {
        return [self substringToIndex:([self length] - 1)];
    }
    else
    {
        return self;
    }
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
