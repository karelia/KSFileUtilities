//
//  KSWebLocationPasteboardUtilities.h
//
//  Created by Mike Abdullah
//  Copyright © 2008 Karelia Software
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

#import "KSWebLocation.h"
#import <WebKit/WebKit.h>


/* The NSPasteboardReading protocol enables instances of a class to be created from pasteboard data by using the -readObjectsForClasses:options: method of NSPasteboard.  The Cocoa framework classes NSString, NSAttributedString, NSURL, NSColor, NSSound, NSImage, and NSPasteboardItem implement this protocol.  The protocol can also be implemented by custom application classes for use with -readObjectsForClasses:options:
 */ 


#if (defined MAC_OS_X_VERSION_10_6) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6
@interface KSWebLocation (Pasteboard) <NSPasteboardReading>
#else
@interface KSWebLocation (Pasteboard)
#endif

#pragma mark Pasteboard Reading
+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard;
- (id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type;


#pragma mark URL Guessing
+ (NSURL *)URLFromPasteboard:(NSPasteboard *)pboard;   // like the WebView method, but takes advantage of NSTextCheckingTypeLink on 10.6+


#pragma mark 10.5 Pasteboard Support
+ (NSArray *)webLocationPasteboardTypes;

@end


#pragma mark -


@interface NSPasteboard (KSWebLocation)
// If the pboard doesn't explicitly contain a title for a location, it's guessed from the URL:
// 1. last path component
// 2. minus path extension
// 3. any underscores converted to spaces
- (NSArray *)readWebLocations;
@end
