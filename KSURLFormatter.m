//
//  KSURLFormatter.m
//
//  Copyright (c) 2008-2012 Mike Abdullah and Karelia Software
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
//  DISCLAIMED. IN NO EVENT SHALL MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//


#import "KSURLFormatter.h"

#import "KSURLUtilities.h"


@implementation KSURLFormatter

#pragma mark Class Methods

+ (NSURL *)URLFromString:(NSString *)string;
{
    // Encode the URL string
    CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                        (CFStringRef)string,
                                                                        (CFStringRef)@"%+#",
                                                                        NULL,
                                                                        kCFStringEncodingUTF8);
    
    
    // If we're still left with a valid string, turn it into a URL
    NSURL *result = nil;
    if (escapedString)
    {
        result = [NSURL URLWithString:(NSString *)escapedString];
        CFRelease(escapedString);
    }
    
    return result;
}

+ (BOOL)isValidEmailAddress:(NSString *)address;
{
    // for now, just validate that syntactically it it at least _@_.__
	// though we are not checking actual other characters.
    // we can refine this over time
    NSRange whereAt = [address rangeOfString:@"@"];
    BOOL OK = (whereAt.location != NSNotFound && whereAt.location >= 1);	// make sure there is an @ and it's not the first character
	if (OK)
	{
		NSInteger len = [address length] - whereAt.location;
		NSRange whereDot = [address rangeOfString:@"." options:0 range:NSMakeRange(whereAt.location, len)];
		OK = (whereDot.location != NSNotFound);
		if (OK)
		{
			// make sure there is room between the @ and the .
			OK = (whereDot.location - whereAt.location >= 2) && ([address length] - whereDot.location >= 3);
		}
	}
	return OK;
}

#pragma mark Init & Dealloc

- (id)init
{
    [super init];
    
    _defaultScheme = [@"http" retain];
    _fallbackTopLevelDomain = [@"com" retain];
    
    return self;
}

- (void)dealloc
{
    [_defaultScheme release];
    [_allowedSchemes release];
    [_fallbackTopLevelDomain release];
    [super dealloc];
}

#pragma mark Managing Behaviour

@synthesize useDisplayNameForFileURLs = _useDisplayNameForFileURLs;
@synthesize defaultScheme = _defaultScheme;

@synthesize allowedSchemes = _allowedSchemes;
- (void)setAllowedSchemes:(NSArray *)schemes;
{
    if (schemes) NSParameterAssert([schemes count] > 0);
    
    schemes = [schemes copy];
    [_allowedSchemes release]; _allowedSchemes = schemes;
}

@synthesize fallbackTopLevelDomain = _fallbackTopLevelDomain;

#pragma mark Textual Representation of Cell Content

- (NSString *)stringForObjectValue:(id)anObject
{
    if (!anObject) return nil;
    if (![anObject isKindOfClass:[NSURL class]]) return [anObject description];
    
    
    NSURL *URL = anObject;
    
    NSString *result;
    if ([self useDisplayNameForFileURLs] && [anObject isFileURL])
    {
        result = [[NSFileManager defaultManager] displayNameAtPath:[URL path]];
    }
    else
    {
        result = [URL absoluteString];
        
        // Append trailing slash if needed
        if ([URL ks_hasNetworkLocation] && [[URL path] isEqualToString:@""])
        {
            result = [result stringByAppendingString:@"/"];
        }
    }
    
    return result;
}

#pragma mark Object Equivalent to Textual Representation

+ (NSURL *)URLFromString:(NSString *)string defaultScheme:(NSString *)fallbackScheme;
{
	//  Tries to interpret the string as a complete URL. If there is no scheme specified, try it as an email address. If that doesn't seem reasonable, combine with fallbackScheme

    
    NSURL *result = [self URLFromString:string];
    
    
    // Allow fragment links as-is
	if ([string hasPrefix:@"#"] && ([string length] > [@"#" length] && result))
    {
        return result;
    }
    
    
	// This is probably a really naive check
	if ((![result scheme] && ![string hasPrefix:@"/"]) ||   // e.g. foo
        (![result host]))                                   // e.g. foo.com:8888
	{
        // if it looks like an email address, use mailto:
        if ([self isValidEmailAddress:string])
        {
            result = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", string]];
        }
        else
        {
            result = [self URLFromString:[NSString stringWithFormat:
                                                   @"%@://%@",
                                                   fallbackScheme,
                                                   string]];
        }
	}
    
    
    // Append a trailing slash if needed
    if ([result ks_hasNetworkLocation] && [[result path] isEqualToString:@""])
    {
        result = [[NSURL URLWithString:@"/" relativeToURL:result] absoluteURL];
    }
	
    return result;
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error
{
    if (anObject)
    {
        NSURL *URL = [self URLFromString:string];
        if ([self generatesURLStrings])
        {
            *anObject = [URL absoluteString];
        }
        else
        {
            *anObject = URL;
        }
    }
    
    return YES;
}

- (NSURL *)URLFromString:(NSString *)string;
{
    NSURL *result = nil;
    
    if ([string length] > 0)
    {
        result = [KSURLFormatter URLFromString:string defaultScheme:[self defaultScheme]];
        
        
        // Does the URL have no useful resource specified? If so, generate nil URL
        if (result && ![[result scheme] isEqualToString:@"mailto"])
        {
            NSString *resource = [result resourceSpecifier];
            if ([resource length] == 0 ||
                [resource isEqualToString:@"/"] ||
                [resource isEqualToString:@"//"])
            {
                result = nil;
            }
            
            
            
            // URLs should also really have a host and a path
            if (result)
            {
                NSString *host = [result host];
                NSString *path = [result path];
                if (!host && !path && ![result fragment])
                {
                    result = nil;
                }
            }
        }
        
        
        // Did the user not enter a top-level domain? We'll guess for them
        if (result && [self fallbackTopLevelDomain])
        {
            if ([[result ks_domains] count] == 1)
            {
                NSString *urlString = [NSString stringWithFormat:
                                       @"%@://%@.%@/",
                                       [result scheme],
                                       [result host],
                                       [self fallbackTopLevelDomain]];
                result = [NSURL URLWithString:urlString];
            }
        }
        
        
        // Make sure the scheme is allowed
        NSArray *allowedSchemes = [self allowedSchemes];
        if (allowedSchemes)
        {
            NSString *scheme = [result scheme];
            if (scheme && ![allowedSchemes containsObject:[result scheme]])
            {
                // Look for the best matching scheme based on the assumption that the URL was simply pasted in missing a small number of initial characters
                for (NSString *aScheme in allowedSchemes)
                {
                    if ([aScheme hasSuffix:scheme])
                    {
                        result = [result ks_URLWithScheme:aScheme];
                        return result;
                    }
                }
                
                // Nothing matched? Alright, go for the first one then
                result = [result ks_URLWithScheme:[allowedSchemes objectAtIndex:0]];
            }
        }
    }
    
    return result;
}

@synthesize generatesURLStrings = _generateStrings;

@end
