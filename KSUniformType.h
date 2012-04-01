//
//  KSUniformType.h
//  Sandvox
//
//  Created by Mike Abdullah on 01/04/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSUniformType : NSObject

+ (NSString *)MIMETypeForType:(NSString *)aUTI;
+ (NSString *)OSTypeStringForType:(NSString *)aUTI;
+ (OSType)OSTypeForType:(NSString *)aUTI;

// Unlike -typeOfFile:error: this will fallback to guessing from the path extension
+ (NSString *)typeOfFileAtURL:(NSURL *)url;

+ (NSString *)typeForFilenameExtension:(NSString *)anExtension;
+ (NSString *)typeForMIMEType:(NSString *)aMIMEType;
+ (NSString *)typeForOSTypeString:(NSString *)aFileType;
+ (NSString *)typeForOSType:(OSType)anOSType;

+ (BOOL)type:(NSString *)type1 isEqualToType:(NSString *)anotherUTI;
+ (BOOL)type:(NSString *)type conformsToOneOfTypes:(NSArray *)types;

@end
