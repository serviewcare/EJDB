#import "EJDBKit.h"
#import "EJDBPlugin.h"
#import <Foundation/Foundation.h>

@implementation EJDBPlugin

static EJDBDatabase *jb;

static NSMutableDictionary *collectionHandles = NULL;

- (CDVPluginResult*) createDatabaseWithPath:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = [command callbackId];

    NSString* path = [[command arguments] objectAtIndex:0];

    // Initialize collection handles.
    collectionHandles = [[NSMutableDictionary alloc] init];
    
    jb = [[EJDBDatabase alloc] initWithPath: path dbFileName:@"silversearch.db"];
    
    CDVPluginResult* result = [CDVPluginResult
              resultWithStatus:CDVCommandStatus_ERROR];
    
    if (jb) {
        result = [CDVPluginResult
                  resultWithStatus:CDVCommandStatus_OK];
        [self success:result callbackId:callbackId];
    }
    else {
        [self error:result callbackId:callbackId];
    }
    
    return result;
}

- (CDVPluginResult*) collectionWithName:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = [command callbackId];
    
    NSString* name = [[command arguments] objectAtIndex:0];

    EJDBCollection *collection = [[EJDBCollection alloc]initWithName:name db:jb];
    
    // This creates the collection for you if it doesn't already exist
    [collection openWithError:NULL];
    
    //Already have one that you want to retrieve?
    collection = [EJDBCollection collectionWithName:name db:jb];

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_ERROR];

    if (collection) {
    
        // Save collection instance by name.
        [collectionHandles setObject: collection forKey: name];

        result = [CDVPluginResult
                  resultWithStatus:CDVCommandStatus_OK];
        [self success:result callbackId:callbackId];
    }
    else {
        [self error:result callbackId:callbackId];
    }
    
    return result;
}

- (CDVPluginResult*) saveObject:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = [command callbackId];
    
    NSString* name = [[command arguments] objectAtIndex:0];
    NSString* json = [[command arguments] objectAtIndex:1];
    
    // Find collection by the name handle.
    EJDBCollection *collection = (EJDBCollection*)[collectionHandles objectForKey: name];
    
    NSError* error;
    NSData* objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:objectData options:kNilOptions error:&error];
    
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_ERROR];
    
    if (collection && objectData && jsonDict) {
        [collection saveObject: jsonDict];

        result = [CDVPluginResult
                  resultWithStatus:CDVCommandStatus_OK];
        [self success:result callbackId:callbackId];
    }
    else {
        [self error:result callbackId:callbackId];
    }
    
    
    return result;
}

- (CDVPluginResult*) find:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = [command callbackId];
    
    NSString* name = [[command arguments] objectAtIndex:0];
    NSString* query = [[command arguments] objectAtIndex:1];
    
    // Find collection by the name handle.
    EJDBCollection *collection = (EJDBCollection*)[collectionHandles objectForKey: name];
    
    NSError* error;
    NSData* objectData = [query dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:objectData options:kNilOptions error:&error];
    
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_ERROR];
    
    if (collection && objectData && jsonDict) {
        EJDBQuery *query = [[EJDBQuery alloc]initWithCollection:collection
                                                          query:jsonDict];

        NSArray* results = [query fetchObjects];
        NSMutableDictionary *postDict = [[NSMutableDictionary alloc]init];
        [postDict setValue:results forKey:@"results"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postDict options:0 error:nil];
        
        result = [CDVPluginResult
                  resultWithStatus:CDVCommandStatus_OK
                  messageAsString: jsonData];

        [self success:result callbackId:callbackId];
    }
    else {
        [self error:result callbackId:callbackId];
    }
    
    return result;
}

- (CDVPluginResult*) remove:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = [command callbackId];
    
    NSString* name = [[command arguments] objectAtIndex:0];
    NSString* uid = [[command arguments] objectAtIndex:1];
    
    // Find collection by the name handle.
    EJDBCollection *collection = (EJDBCollection*)[collectionHandles objectForKey: name];
    
    NSError* error;

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_ERROR];
    
    if (collection) {
        [collection removeObjectWithOID:uid];
        
        result = [CDVPluginResult
                  resultWithStatus:CDVCommandStatus_OK];
        [self success:result callbackId:callbackId];
    }
    else {
        [self error:result callbackId:callbackId];
    }
    
    return result;
}

/*
- (void)init:(CDVInvokedUrlCommand*)command
{

    NSString* callbackId = [command callbackId];
    NSString* name = [[command arguments] objectAtIndex:0];
    NSString* msg = [NSString stringWithFormat: @"Hello, %@", name];

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:msg];

    #if TARGET_IPHONE_SIMULATOR
    #else
    #endif

    [self success:result callbackId:callbackId];
}
 */

@end
