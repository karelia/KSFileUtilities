//
//  KSUniformType.h
//  Sandvox
//
//  Created by Mike Abdullah on 01/04/2012.
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

#import <Foundation/Foundation.h>

@interface KSUniformType : NSObject
{
  @private
    NSString    *_identifier;
}

+ (NSString *)MIMETypeForType:(NSString *)aUTI;
+ (NSString *)OSTypeStringForType:(NSString *)aUTI;
+ (OSType)OSTypeForType:(NSString *)aUTI;

// Unlike -typeOfFile:error: this will fallback to guessing from the path extension
+ (NSString *)typeOfFileAtURL:(NSURL *)url;

+ (NSString *)typeForFilenameExtension:(NSString *)anExtension;
+ (NSString *)typeForMIMEType:(NSString *)aMIMEType;
+ (NSString *)typeForOSTypeString:(NSString *)aFileType;
+ (NSString *)typeForOSType:(OSType)anOSType;


#pragma mark Creating a KSUniformType Instance

+ (instancetype)uniformTypeWithFilenameExtension:(NSString *)extension;
+ (instancetype)bestGuessUniformTypeForURL:(NSURL *)url;
+ (instancetype)uniformTypeWithIdentifier:(NSString *)identifier; // lenient and handles nil identifier by returning nil

// KSUniformType returns the right to return nil should the identifier be unsuitable (a la NSURL). This doesn't happen at present though
// Designated initializer
- (id)initWithIdentifier:(NSString *)uti;


#pragma mark Properties
@property(nonatomic, readonly, copy) NSString *identifier;
- (NSString *)MIMEType;


#pragma mark Testing Uniform Type Identifiers

// Equality is determined by UTTypeEqual(). As a result, all KSUniformType instances have the same hash, and so are poor for placing in sets and as dictionary keys
- (BOOL)isEqualToType:(NSString *)type;

- (BOOL)conformsToType:(NSString *)type;
+ (BOOL)type:(NSString *)type1 isEqualToType:(NSString *)anotherUTI;
+ (BOOL)type:(NSString *)type conformsToOneOfTypes:(NSArray *)types;


@end
