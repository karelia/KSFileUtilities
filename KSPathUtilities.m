//
//  KSPathUtilities.m
//  Sandvox
//
//  Created by Mike Abdullah on 09/09/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "KSPathUtilities.h"


@implementation NSString (KSPathUtilities)

- (NSString *)ks_pathRelativeToDirectory:(NSString *)dirPath
{
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
    BOOL result = [adjustedMePath hasPrefix:adjustedOtherPath];
    return result;
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
