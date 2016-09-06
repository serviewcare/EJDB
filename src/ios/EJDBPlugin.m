#import "EJDBKit.h"
#import "EJDBPlugin.h"
#import "NSData+GZIP.h"
#import <Foundation/Foundation.h>

@implementation EJDBPlugin

static EJDBDatabase *jb = nil;

static NSMutableDictionary *collectionHandles = nil;


- (void) createDatabaseWithPath:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString* payload = nil;
        @synchronized(self) {
            NSString* callbackId = [command callbackId];
            
            NSString* path = [[command arguments] objectAtIndex:0];
            
            if (jb && [jb isOpen]) {
                [jb close];
            }
            
            // Initialize collection handles.
            collectionHandles = [[NSMutableDictionary alloc] init];
            
            
            BOOL opened = false;
            // All data will be saved to silversearch.db file.
            jb = [[EJDBDatabase alloc] initWithPath: path dbFileName:@"silversearch.db"];
            
            if (jb) {
                opened = [jb openWithError: NULL];
            }
            CDVPluginResult* result = nil;
            
            if (jb && opened) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            } else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
            
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:payload];
        // The sendPluginResult method is thread-safe.
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) initializeCollectionWithName:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString* payload = nil;
        @synchronized(self) {
            NSString* callbackId = [command callbackId];
            
            NSString* name = [[command arguments] objectAtIndex:0];
            
            // These operations were happening in the ensureCollectionWithName method so
            // they were commented out.  No ill side effects have been observed thus far.
            //EJDBCollection *collection = [[EJDBCollection alloc]initWithName:name db:jb];
            
            // This creates the collection for you if it doesn't already exist
            //[collection openWithError:NULL];
            
            //Already have one that you want to retrieve?
            EJDBCollection* collection = [jb ensureCollectionWithName:name error: NULL];
            
            CDVPluginResult* result = nil;
            
            if ((collection)) {
                // Save collection instance by name.
                [collectionHandles setObject: collection forKey: name];
                
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            } else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
            
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:payload];
        // The sendPluginResult method is thread-safe.
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) saveObjects:(CDVInvokedUrlCommand*)command {
    // Check command.arguments here.
    [self.commandDelegate runInBackground:^{
        NSString* payload = nil;
        @synchronized(self) {
            NSString* callbackId = [command callbackId];
            
            NSString* name = [[command arguments] objectAtIndex:0];
            NSString* json = [[command arguments] objectAtIndex:1];
            
            // Find collection by the name handle.
            EJDBCollection *collection = (EJDBCollection*)[collectionHandles objectForKey: name];
            
            NSError* error;
            NSData* objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:objectData options:kNilOptions error:&error];
            
            NSArray *jsonArr = [jsonDict objectForKey:@"ns"];
            
            CDVPluginResult* result = nil;
            
            if (collection && objectData && jsonDict && jsonArr && [collection saveObjects: jsonArr]) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            } else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
            
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:payload];
        // The sendPluginResult method is thread-safe.
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}


- (void) saveObject:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString* payload = nil;
        @synchronized(self) {
            NSString* callbackId = [command callbackId];
            
            NSString* name = [[command arguments] objectAtIndex:0];
            NSString* json = [[command arguments] objectAtIndex:1];
            
            // Find collection by the name handle.
            EJDBCollection *collection = (EJDBCollection*)[collectionHandles objectForKey: name];
            
            NSError* error;
            NSData* objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:objectData options:kNilOptions error:&error];
            
            
            CDVPluginResult* result = nil;
            
            if (collection && objectData && jsonDict && [collection saveObject: jsonDict]) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            } else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
            
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:payload];
        // The sendPluginResult method is thread-safe.
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) find:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString* payload = nil;
        @synchronized(self) {
            NSString* callbackId = [command callbackId];
            
            NSString* name = [[command arguments] objectAtIndex:0];
            NSString* query = [[command arguments] objectAtIndex:1];
            NSString* hint = [[command arguments] objectAtIndex:2];
            
            // Find collection by the name handle.
            EJDBCollection *collection = (EJDBCollection*)[collectionHandles objectForKey: name];
            
            NSError* error;
            NSData* objectData = [query dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:objectData options:kNilOptions error:&error];
            
            NSData* hintData = [hint dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary* hintDict = [NSJSONSerialization JSONObjectWithData:hintData options:kNilOptions error:&error];
            
            
            CDVPluginResult* result = nil;
            
            if (collection && objectData && jsonDict) {
                NSArray* results = [jb findObjectsWithQuery:jsonDict hints:hintDict inCollection:collection error:&error];
                
                NSMutableDictionary *postDict = [[NSMutableDictionary alloc]init];
                [postDict setValue:results forKey:@"results"];
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postDict options:0 error:nil];
                NSData* zippedData = [jsonData gzippedData];
                NSString* base64Encoded = [zippedData base64EncodedStringWithOptions:0];
                
                if (!jsonData) {
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                } else {
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: base64Encoded];
                }
            } else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
            
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:payload];
        // The sendPluginResult method is thread-safe.
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) remove:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString* payload = nil;
        @synchronized(self) {
            NSString* callbackId = [command callbackId];
            
            NSString* name = [[command arguments] objectAtIndex:0];
            NSString* uid = [[command arguments] objectAtIndex:1];
            
            // Find collection by the name handle.
            EJDBCollection *collection = (EJDBCollection*)[collectionHandles objectForKey: name];
            
            CDVPluginResult* result = nil;
            
            if (collection && [collection removeObjectWithOID:uid]) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            } else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
            
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:payload];
        // The sendPluginResult method is thread-safe.
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) count:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString* payload = nil;
        @synchronized(self) {
            NSString* callbackId = [command callbackId];
            
            NSString* name = [[command arguments] objectAtIndex:0];
            NSString* query = [[command arguments] objectAtIndex:1];
            NSString* hint = [[command arguments] objectAtIndex:2];
            
            // Find collection by the name handle.
            EJDBCollection *collection = (EJDBCollection*)[collectionHandles objectForKey: name];
            
            NSError* error;
            NSData* objectData = [query dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:objectData options:kNilOptions error:&error];
            
            NSData* hintData = [hint dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary* hintDict = [NSJSONSerialization JSONObjectWithData:hintData options:kNilOptions error:&error];
            
            CDVPluginResult* result = nil;
            
            if (collection && objectData && jsonDict) {
                EJDBQuery* query = [jb createQuery:jsonDict hints:hintDict forCollection:collection];
                
                uint32_t numResults = [query fetchCountWithError:&error];
                
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt: numResults];
            } else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
            
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:payload];
        // The sendPluginResult method is thread-safe.
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) setIndexOption:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString* payload = nil;
        @synchronized(self) {
            NSString* callbackId = [command callbackId];
            
            NSString* name = [[command arguments] objectAtIndex:0];
            NSString* optionStr = [[command arguments] objectAtIndex:1];
            NSString* fieldPath = [[command arguments] objectAtIndex:2];
            
            // Find collection by the name handle.
            EJDBCollection *collection = (EJDBCollection*)[collectionHandles objectForKey: name];
            
            // Convert string option into the enum value (hacky I know, but Objective-C doesn't support switch on strings)
            EJDBIndexOptions option;
            if ([optionStr isEqualToString:@"EJDBIndexDrop"]) {
                option = EJDBIndexDrop;
            } else if ([optionStr isEqualToString:@"EJDBIndexDropAll"]) {
                option = EJDBIndexDropAll;
            } else if ([optionStr isEqualToString:@"EJDBIndexOptimize"]) {
                option = EJDBIndexOptimize;
            } else if ([optionStr isEqualToString:@"EJDBIndexRebuild"]) {
                option = EJDBIndexRebuild;
            } else if ([optionStr isEqualToString:@"EJDBIndexNumber"]) {
                option = EJDBIndexNumber;
            } else if ([optionStr isEqualToString:@"EJDBIndexString"]) {
                option = EJDBIndexString;
            } else if ([optionStr isEqualToString:@"EJDBIndexArray"]) {
                option = EJDBIndexArray;
            } else if ([optionStr isEqualToString:@"EJDBIndexStringCaseInsensitive"]) {
                option = EJDBIndexStringCaseInsensitive;
            }
            
            
            CDVPluginResult* result = nil;
            
            if (collection && option && fieldPath && [collection setIndexOption:option forFieldPath:fieldPath]) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            } else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
            
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:payload];
        // The sendPluginResult method is thread-safe.
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
