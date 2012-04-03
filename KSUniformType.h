//
//  KSUniformType.h
//  Sandvox
//
//  Created by Mike Abdullah on 01/04/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
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

+ (id)uniformTypeWithFilenameExtension:(NSString *)extension;
+ (id)bestGuessUniformTypeForURL:(NSURL *)url;
+ (id)uniformTypeWithIdentifier:(NSString *)identifier; // lenient and handles nil identifier by returning nil

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
