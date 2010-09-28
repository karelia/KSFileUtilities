//
//  KSWebLocation.m
//
//  Copyright (c) 2007-2010, Mike Abdullah, Dan Wood and Karelia Software
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
//  DISCLAIMED. IN NO EVENT SHALL MIKE ABDULLAH, DAN WOOD OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//


#import "KSWebLocation.h"

#import "KSURLUtilities.h"


@interface KSWebLocation (Private)
+ (NSArray *)webLocationsWithBookmarkDictionariesPasteboardPropertyList:(id)propertyList;
+ (NSArray *)webLocationsWithWebURLsWithTitlesPasteboardPropertyList:(id)propertyList;
+ (NSArray *)webLocationsWithFilenamesPasteboardPropertyList:(id)propertyList;
+ (NSArray *)_basicURLsFromPasteboard:(NSPasteboard *)pasteboard;
+ (NSArray *)_basicURLsFromPasteboardString:(NSString *)string;

// Utility
+ (NSURL *)URLWithString:(NSString *)string;
+ (NSData *)readFromResourceFileAtPath:(NSString *)aPath type:(ResType)aType named:(NSString *)aName id:(NSInteger)anID;
@end


#pragma mark -


@implementation KSWebLocation

+ (id)webLocationWithURL:(NSURL *)URL;
{
    return [self webLocationWithURL:URL title:nil];
}

+ (id)webLocationWithURL:(NSURL *)URL title:(NSString *)title
{
	return [[[self alloc] initWithURL:URL title:title] autorelease];
}

#pragma mark Init & Dealloc

- (id)initWithURL:(NSURL *)URL title:(NSString *)name
{
	NSParameterAssert(URL);
	
	if (self = [super init])
	{
		_URL = [URL copy];
		_title = [name copy];
	}
	
	return self;
}

- (id)init
{
	return [self initWithURL:nil title:nil];
}

- (void)dealloc
{
	[_URL release];
	[_title release];
	
	[super dealloc];
}

#pragma mark Accessors

- (NSURL *)URL { return _URL; }

- (NSString *)title { return _title; }

#pragma mark Equality

- (NSUInteger)hash
{
	NSUInteger result = [[self URL] hash] | [[self title] hash];
	return result;
}

- (BOOL)isEqual:(id)anObject
{
	if (self == anObject)
	{
		return YES;
	}
	else if ([anObject isKindOfClass:[KSWebLocation class]])
	{
		return [self isEqualToWebLocation:anObject];
	}
	else
	{
		return NO;
	}
}

- (BOOL)isEqualToWebLocation:(KSWebLocation *)aWebLocation
{
	BOOL result = [[aWebLocation URL] isEqual:[self URL]] && [[aWebLocation title] isEqualToString:[self title]];
	return result;
}

#pragma mark Copying

- (id)copyWithZone:(NSZone *)zone
{
	// KSWebLocations are effectively immutable (could add a mutable subclass if needed in the future) so retain
	return [self retain];
}

#pragma mark Archiving

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:[self URL] forKey:@"URL"];
	[encoder encodeObject:[self title] forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if (self = [super init])
	{
		_URL = [[decoder decodeObjectForKey:@"URL"] retain];
		_title = [[decoder decodeObjectForKey:@"name"] retain];
	}
	
	return self;
}

#pragma mark Pasteboard Reading

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard;
{
    NSArray *URLTypes = nil;
    if ([NSURL respondsToSelector:@selector(readableTypesForPasteboard:)])
    {
        URLTypes = [NSURL performSelector:@selector(readableTypesForPasteboard:)
                               withObject:pasteboard];
    }
    
    NSArray *result = [NSArray arrayWithObjects:
                       NSURLPboardType,
                       NSStringPboardType,
                       NSRTFPboardType,
                       NSRTFDPboardType, nil];
    
    if (URLTypes) result = [URLTypes arrayByAddingObjectsFromArray:result];
    return result;
}

#if (defined MAC_OS_X_VERSION_10_6) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6
+ (NSUInteger)readingOptionsForType:(NSString *)type
                                         pasteboard:(NSPasteboard *)pasteboard;
{
    NSPasteboardReadingOptions result = NSPasteboardReadingAsString;
    
    if ([type isEqualToString:@"WebURLsWithTitlesPboardType"] ||
        [type isEqualToString:@"BookmarkDictionaryListPboardType"] ||
        [type isEqualToString:NSFilenamesPboardType])
    {
        result = NSPasteboardReadingAsPropertyList;
    }
    
    return result;
}
#endif

- (id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type;
{
    // Try with NSURL
    NSURL *URL = [[NSURL alloc] initWithPasteboardPropertyList:propertyList ofType:type];
    if (URL)
    {
        self = [self initWithURL:URL title:nil];
        [URL release];
    }
    
    // Fallback to trying to get a string out of the plist
    else
    {
        NSString *string = [propertyList description];
        if ([string length] <= 2048)	// No point processing particularly long strings
        {
            NSURL *URL = [[self class] URLWithString:string];	/// encodeLegally to handle accented characters
            if (URL && [URL ks_hasNetworkLocation])
            {
                self = [self initWithURL:URL title:nil];
            }
            else
            {
                [self release]; self = nil;
            }
        }
	}
        
    return self;
}

#pragma mark Support

+ (NSURL *)URLWithString:(NSString *)string;
{
    // Encode the URL string
    CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
    CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                        (CFStringRef)string,
                                                                        (CFStringRef)@"%+#",
                                                                        NULL,
                                                                        encoding);
    
    
    // If we're still left with a valid string, turn it into a URL
    NSURL *result = nil;
    if (escapedString)
    {
        result = [NSURL URLWithString:string];
        CFRelease(escapedString);
    }
    
    return result;
}

// Pass in nil for aName if we want to use ID
+ (NSData *)readFromResourceFileAtPath:(NSString *)aPath type:(ResType) aType named:(NSString *)aName id:(NSInteger)anID
{
	NSInteger	fileRef = 0;
	NSData *result = nil;
	@try
	{
		FSRef theFSRef;
		if (noErr == FSPathMakeRef((const UInt8 *)[aPath UTF8String], &theFSRef, NULL ))
		{
			fileRef = FSOpenResFile(&theFSRef, fsRdPerm);
			if (noErr == ResError())
			{
				Handle		theResHandle = NULL;
				NSInteger	thePreviousRefNum = CurResFile();	// save current resource
				Str255		thePName;
				
				UseResFile(fileRef);    		// set this resource to be current
				
				if (noErr ==  ResError())
				{
					if (aName)	// use name
					{
						Str255 pString;
						// Create pascal string -- assume MacRoman encoding for resource names?
						BOOL success = CFStringGetPascalString((CFStringRef)aName,
															   pString,
															   [aName length],
															   kCFStringEncodingMacRomanLatin1);
						if (success)
						{
							theResHandle = Get1NamedResource( aType, thePName );
						}
					}
					else	// use ID
					{
						theResHandle = Get1Resource( aType, anID );
					}	
					
					if (theResHandle && noErr == ResError())
					{
						// Wow, this is a trip down memory lane for Dan!
						HLock(theResHandle);
						result = [NSData dataWithBytes:*theResHandle length:GetHandleSize(theResHandle)];
						HUnlock(theResHandle);
						ReleaseResource(theResHandle);
					}
				}
				UseResFile( thePreviousRefNum );     		// reset back to resource previously set
			}
		}
	}
	@finally
	{
		if( fileRef > 0)
		{
			CloseResFile(fileRef);
		}
	}
	return result;
}

#pragma mark Deprecated

+ (NSArray *)webLocationPasteboardTypes
{
    return [NSArray arrayWithObjects:
			@"WebURLsWithTitlesPboardType",
			@"BookmarkDictionaryListPboardType",
            NSFilenamesPboardType,
			NSURLPboardType,
			NSStringPboardType,
			NSRTFPboardType,
			NSRTFDPboardType, nil];
}

/*	Retrieve URLs and their titles from the pasteboard for the "BookmarkDictionaryListPboardType" type
 */
+ (NSArray *)webLocationsWithBookmarkDictionariesPasteboardPropertyList:(id)propertyList;
{
	NSArray *result = nil;
	
	NSArray *arrayFromData = propertyList;
	if (arrayFromData && [arrayFromData isKindOfClass:[NSArray class]] && [arrayFromData count] > 0)
	{
		NSDictionary *objectInfo = [arrayFromData objectAtIndex:0];
		if ([objectInfo isKindOfClass:[NSDictionary class]])
		{
			NSString *URLString = [objectInfo objectForKey:@"URLString"];
			NSURL *URL = [[self class] URLWithString:URLString];	/// encodeLegally to handle accented characters
			
			if (URL)
			{
				NSString *title = [[objectInfo objectForKey:@"URIDictionary"] objectForKey:@"title"];
				
				KSWebLocation *webLoc = [[KSWebLocation alloc] initWithURL:URL title:title];
				result = [NSArray arrayWithObject:webLoc];
				[webLoc release];
			}
		}
	}
	
	return result;
}

/*	Retrieve URLs and their titles from the pasteboard for the "WebURLsWithTitlesPboardType" type
 *	/// Rewritten 1/5/07 to account for being passed a nil URL
 */
+ (NSArray *)webLocationsWithWebURLsWithTitlesPasteboardPropertyList:(id)propertyList
{
	NSMutableArray *result = nil;
	
	// Bail if we haven't been handed decent data
	NSArray *rawDataArray = propertyList;
	if (rawDataArray && [rawDataArray isKindOfClass:[NSArray class]] && [rawDataArray count] >= 2) 
	{
		// Get the array of URLs and their titles
		NSArray *URLStrings = [rawDataArray objectAtIndex:0];
		NSArray *URLTitles = [rawDataArray objectAtIndex:1];
		
		
		// Run through each URL
		result = [NSMutableArray arrayWithCapacity:[URLStrings count]];
		
		NSInteger i;
		for (i=0; i<[URLStrings count]; i++)
		{
			// Convert the string to a proper URL. If actually valid, add it & title to the results
			NSString *URLString = [URLStrings objectAtIndex:i];
			NSURL *URL = [[self class] URLWithString:URLString];	/// encodeLegally to handle accented characters
			if (URL)
			{
				KSWebLocation *aWebLocation = [[KSWebLocation alloc] initWithURL:URL title:[URLTitles objectAtIndex:i]];
				[result addObject:aWebLocation];
				[aWebLocation release];
			}
		}
	}
		
	return result;
}

+ (NSArray *)webLocationsWithFilenamesPasteboardPropertyList:(id)propertyList;
{
    NSArray *filenames = propertyList;
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[filenames count]];
    
    for (NSString *aFilename in filenames)
    {
        NSURL *URL = [NSURL fileURLWithPath:aFilename];
        KSWebLocation *aLocation = [[KSWebLocation alloc] initWithURL:URL title:nil];
        [result addObject:aLocation];
        [aLocation release];
    }
    
    return result;
}

+ (NSArray *)_basicURLsFromPasteboard:(NSPasteboard *)pasteboard
{
	NSArray *result = nil;
	
	NSURL *URL = [NSURL URLFromPasteboard:pasteboard];
	if (URL)
	{
		// We may be able to get title from CorePasteboardFlavorType 'urln'
		NSString *title = nil;
		if ([pasteboard availableTypeFromArray:[NSArray arrayWithObject:@"CorePasteboardFlavorType 0x75726C6E"]]) {
			title = [pasteboard stringForType:@"CorePasteboardFlavorType 0x75726C6E"];
		}
		
		KSWebLocation *webLocation = [[KSWebLocation alloc] initWithURL:URL title:title];
		result = [NSArray arrayWithObject:webLocation];
		[webLocation release];
	}
	
	return result;
}

@end


#pragma mark -


@implementation KSWebLocation (WeblocFiles)

+ (id)webLocationWithContentsOfWeblocFile:(NSURL *)weblocURL
{
	return [[[self alloc] initWithContentsOfWeblocFile:weblocURL] autorelease];
}

- (id)initWithContentsOfWeblocFile:(NSURL *)weblocURL
{
	NSString *weblocPath = [weblocURL path];
	
	// Use the Carbon Resource Manager to read 'url ' resource #256.
	// String sems to be pre ASCII, with 2-bytes converted to % escapes
	NSData *urlData = [[self class] readFromResourceFileAtPath:weblocPath
                                                          type:'url '
                                                         named:nil
                                                            id:256];
	
	NSString *URLString = [[NSString alloc] initWithData:urlData encoding:NSASCIIStringEncoding];
	NSURL *URL = [[self class] URLWithString:URLString];
    [URLString release];
	
	
	// Use the Carbon Resource Manager to read 'urln' resource #256.
	// empirically, this seems to be UTF8 encoded.
	NSData *nameData = [[self class] readFromResourceFileAtPath:weblocPath
                                                           type:'urln'
                                                          named:nil
                                                             id:256];
	
	NSString *nameString = [[NSString alloc] initWithData:nameData
                                                 encoding:NSUTF8StringEncoding];
	
	self = [self initWithURL:URL title:nameString];
    
    [nameString release];
    return self;
}

@end


#pragma mark -


@implementation NSPasteboard (KSWebLocation)

- (NSArray *)readWebLocations;
{
	NSArray *result = nil;
	
	// Get the URLs and titles from the best type available on the pasteboard
	NSString *bestPboardType = [self availableTypeFromArray:
                                [KSWebLocation webLocationPasteboardTypes]];
    
	if (bestPboardType)
	{
		if ([bestPboardType isEqualToString:@"BookmarkDictionaryListPboardType"])
        {
			result = [KSWebLocation webLocationsWithBookmarkDictionariesPasteboardPropertyList:
                      [self propertyListForType:bestPboardType]];
		}
		else if ([bestPboardType isEqualToString:@"WebURLsWithTitlesPboardType"])
        {
            result = [KSWebLocation webLocationsWithWebURLsWithTitlesPasteboardPropertyList:
                      [self propertyListForType:bestPboardType]];
		}
        else if ([bestPboardType isEqualToString:NSFilenamesPboardType])
        {
            result = [KSWebLocation webLocationsWithFilenamesPasteboardPropertyList:
                      [self propertyListForType:bestPboardType]];
        }
        else if ([bestPboardType isEqualToString:NSURLPboardType])
        {
            result = [KSWebLocation _basicURLsFromPasteboard:self];
        }
		else	// the fallback option is string parsing
        {
#if (defined MAC_OS_X_VERSION_10_6) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6
            NSPasteboardReadingOptions readingOptions =
            [self readingOptionsForType:bestPboardType pasteboard:self];
            
            id propertyList;
            if (readingOptions & NSPasteboardReadingAsPropertyList)
            {
                propertyList = [self propertyListForType:bestPboardType];
            }
            else if (readingOptions & NSPasteboardReadingAsString)
            {
                propertyList = [self stringForType:bestPboardType];
            }
            else
            {
                propertyList = [self dataForType:bestPboardType];
            }
            
			KSWebLocation *webLocation = [[KSWebLocation alloc]
                                          initWithPasteboardPropertyList:propertyList
                                          ofType:bestPboardType];
            
            result = [NSArray arrayWithObject:webLocation];
            [webLocation release];
#endif
		}
	}
	
	return result;
}

- (NSArray *)readWebLocationsConvertingWeblocFiles:(BOOL)convertWeblocs
                                    ignoreFileURLs:(BOOL)ignoreFileURLs;
{
	// Get the unfiltered URLs
	NSArray *result = [self readWebLocations];
	
	
	if (convertWeblocs || ignoreFileURLs)
	{
		NSMutableArray *buffer = [[NSMutableArray alloc] initWithCapacity:[result count]];
		KSWebLocation *aWebLocation;
		
		for (aWebLocation in result)
		{
			// Convert .webloc files as required
			NSURL *URL = [aWebLocation URL];
			if (convertWeblocs && [URL isFileURL] && [[URL ks_pathExtension] isEqualToString:@"webloc"])
			{
				aWebLocation = [KSWebLocation webLocationWithContentsOfWeblocFile:URL];
			}
			
			// Add the URL to the list unless we've been requested to ignore file URLs
			if (!(ignoreFileURLs && [[aWebLocation URL] isFileURL]))
			{
				[buffer addObject:aWebLocation];
			}
		}
		
		result = [[buffer copy] autorelease];
		[buffer release];
	}
	
	
	// Return
	return result;
}

@end

