//
//  KSWorkspaceUtilities.h
//  Sandvox
//
//  Created by Mike on 28/04/2011.
//  Copyright 2005-2011 Karelia Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSWorkspace (KSWorkspaceUtilities)

#pragma mark Manipulating Uniform Type Identifier Information

- (NSString *)ks_MIMETypeForType:(NSString *)aUTI;
- (NSString *)ks_OSTypeStringForType:(NSString *)aUTI;
- (OSType)ks_OSTypeForType:(NSString *)aUTI;

// Unlike -typeOfFile:error: this will fallback to guessing from the path extension
- (NSString *)ks_typeOfFileAtURL:(NSURL *)url;

- (NSString *)ks_typeForFilenameExtension:(NSString *)anExtension;
- (NSString *)ks_typeForMIMEType:(NSString *)aMIMEType;
- (NSString *)ks_typeForOSTypeString:(NSString *)aFileType;
- (NSString *)ks_typeForOSType:(OSType)anOSType;

- (BOOL)ks_type:(NSString *)type1 isEqualToType:(NSString *)anotherUTI;
- (BOOL)ks_type:(NSString *)type conformsToOneOfTypes:(NSArray *)types;

@end
