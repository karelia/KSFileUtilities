//
//  KSWebLocationPasteboardUtilities.m
//
//  Created by Mike Abdullah
//  Copyright © 2007 Karelia Software
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

#import "KSWebLocationPasteboardUtilities.h"

#import "KSURLFormatter.h"
#import "KSURLUtilities.h"


@interface KSWebLocation (PasteboardPrivate)
+ (NSArray *)webLocationsWithBookmarkDictionariesPasteboardPropertyList:(id)propertyList;
+ (NSArray *)webLocationsWithWebURLsWithTitlesPasteboardPropertyList:(id)propertyList;
+ (NSArray *)webLocationsWithFilenamesPasteboardPropertyList:(id)propertyList;
@end


#pragma mark -


@implementation KSWebLocation (Pasteboard)

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

+ (NSString *)guessTitleForURL:(NSURL *)URL;
{
    NSString *result = [[URL ks_lastPathComponent] stringByDeletingPathExtension];
    result = [result stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    return result;
}

- (id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type;
{
    // Try with NSURL
    NSURL *URL = [[NSURL alloc] initWithPasteboardPropertyList:propertyList ofType:type];
    if (URL)
    {
        self = [self initWithURL:URL title:[[self class] guessTitleForURL:URL]];
        [URL release];
    }
    
    // Fallback to trying to get a string out of the plist
    else
    {
        NSString *string = [propertyList description];
        if ([string length] <= 2048)	// No point processing particularly long strings
        {
            NSURL *plistURL = [KSURLFormatter URLFromString:string];	/// encodeLegally to handle accented characters
            if (plistURL && [plistURL ks_hasNetworkLocation])
            {
                return [self initWithURL:plistURL title:[[self class] guessTitleForURL:URL]];
            }
        }
        
        [self release]; self = nil;
	}
        
    return self;
}

+ (KSWebLocation *)webLocationFromPasteboard:(NSPasteboard *)pasteboard;
{
    KSWebLocation *result = nil;
    
    NSURL *URL = [self URLFromPasteboard:pasteboard];
    if (URL)
    {
        result = [KSWebLocation webLocationWithURL:URL
                                             title:[WebView URLTitleFromPasteboard:pasteboard]];
    }
    
    return result;
}

+ (NSURL *)URLFromPasteboard:(NSPasteboard *)pboard
{
    NSURL *result = [WebView URLFromPasteboard:pboard];
    
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6
    if (!result)
    {
        NSSpellChecker *spellChecker = [NSSpellChecker sharedSpellChecker];
        if ([spellChecker respondsToSelector:@selector(checkString:range:types:options:inSpellDocumentWithTag:orthography:wordCount:)])
        {
            NSString *string = [pboard stringForType:NSStringPboardType];
            
            NSArray *checkResults = [spellChecker checkString:string
                                                        range:NSMakeRange(0, [string length])
                                                        types:(NSTextCheckingTypes)NSTextCheckingTypeLink   // cast to suppress oddity of SDK
                                                      options:nil
                                       inSpellDocumentWithTag:0
                                                  orthography:NULL
                                                    wordCount:NULL];
            
            if ([checkResults count])
            {
                result = [[checkResults objectAtIndex:0] URL];
            }
        }
    }
#endif
    
    return result;
}

#pragma mark Deprecated

+ (NSArray *)webLocationPasteboardTypes
{
    return [NSArray arrayWithObjects:
			@"WebURLsWithTitlesPboardType",
			@"BookmarkDictionaryListPboardType",
            kUTTypeURL,                             // contains the target URL when dragging webloc
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
			NSURL *URL = [KSURLFormatter URLFromString:URLString];	/// encodeLegally to handle accented characters
			
			if (URL)
			{
				NSString *title = [[objectInfo objectForKey:@"URIDictionary"] objectForKey:@"title"];
                if (!title) title = [[self class] guessTitleForURL:URL];
				
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
			NSURL *URL = [KSURLFormatter URLFromString:URLString];	/// encodeLegally to handle accented characters
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
        KSWebLocation *aLocation = [[KSWebLocation alloc] initWithURL:URL title:[[self class] guessTitleForURL:URL]];
        [result addObject:aLocation];
        [aLocation release];
    }
    
    return result;
}

@end


#pragma mark -


@implementation NSPasteboard (KSWebLocation)

- (NSArray *)readWebLocations;
{
	NSArray *result = nil;
	
	// Get the URLs and titles from the best type available on the pasteboard.
	NSString *type = [self availableTypeFromArray:[KSWebLocation webLocationPasteboardTypes]];
    
    // Ideally we want to read multiple kUTTypeURLs, but this requires 10.6 or dropping down to CorePasteboard. So for now, fake it by falling back to NSFilenamesPboardType for file URLs (when possible)
    if ([type isEqualToString:(NSString *)kUTTypeFileURL])
    {
        type = [self availableTypeFromArray:[NSArray arrayWithObjects:
                                             NSFilenamesPboardType,
                                             type,
                                             nil]];
    }
    
    
	if ([type isEqualToString:@"BookmarkDictionaryListPboardType"])
    {
        result = [KSWebLocation webLocationsWithBookmarkDictionariesPasteboardPropertyList:
                  [self propertyListForType:type]];
    }
    else if ([type isEqualToString:@"WebURLsWithTitlesPboardType"])
    {
        result = [KSWebLocation webLocationsWithWebURLsWithTitlesPasteboardPropertyList:
                  [self propertyListForType:type]];
    }
    else if ([type isEqualToString:NSFilenamesPboardType])
    {
        result = [KSWebLocation webLocationsWithFilenamesPasteboardPropertyList:
                  [self propertyListForType:type]];
    }
    else
    {
        KSWebLocation *webloc = [KSWebLocation webLocationFromPasteboard:self];
        if (webloc) result = [NSArray arrayWithObject:webloc];
    }

	
	return result;
}

@end

