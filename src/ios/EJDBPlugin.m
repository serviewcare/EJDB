#import "EJDBKit.h"
#import "EJDBPlugin.h"
#import "NSData+GZIP.h"
#import <Foundation/Foundation.h>

@implementation EJDBPlugin

static EJDBDatabase *jb = nil;

static NSMutableDictionary *collectionHandles = nil;


- (CDVPluginResult*) createDatabaseWithPath:(CDVInvokedUrlCommand*)command {

    @synchronized(self) {
        NSString* callbackId = [command callbackId];
        
        NSString* path = [[command arguments] objectAtIndex:0];
        
        if(jb && [jb isOpen]) {
            [jb close];
        }
        
        // Initialize collection handles.
        collectionHandles = [[NSMutableDictionary alloc] init];
        
        
        BOOL opened = false;
        // All data will be saved to silversearch.db file.
        jb = [[EJDBDatabase alloc] initWithPath: path dbFileName:@"silversearch.db"];
        
        if(jb) {
            opened = [jb openWithError: NULL];
        }
        CDVPluginResult* result = [CDVPluginResult
                  resultWithStatus:CDVCommandStatus_ERROR];
        
        if (jb && opened) {
            result = [CDVPluginResult
                      resultWithStatus:CDVCommandStatus_OK];
            [self success:result callbackId:callbackId];
        }
        else {
            [self error:result callbackId:callbackId];
        }
        
        return result;
    }
    
}

- (CDVPluginResult*) initializeCollectionWithName:(CDVInvokedUrlCommand*)command {
    @synchronized(self) {
        NSString* callbackId = [command callbackId];
        
        NSString* name = [[command arguments] objectAtIndex:0];

        EJDBCollection *collection = [[EJDBCollection alloc]initWithName:name db:jb];
        
        // This creates the collection for you if it doesn't already exist
        [collection openWithError:NULL];
        
        //Already have one that you want to retrieve?
        collection = [jb ensureCollectionWithName:name error: NULL];

        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_ERROR];

        if ((collection)) {
        
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
}

- (CDVPluginResult*) maxDate:(CDVInvokedUrlCommand*)command {
    @synchronized(self) {
        [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
        
        // Max date starts as the earliest date possible.
        NSDate* earliest = [NSDate dateWithTimeIntervalSince1970: 0];
        NSDate* maxDate = earliest;
        
        NSString* callbackId = [command callbackId];
        
        // Now we iterate over all collected collection data.
        for(NSString* collectionName in [collectionHandles allKeys]) {
            // Find collection by the name handle.
            EJDBCollection *collection = (EJDBCollection*)[collectionHandles objectForKey: collectionName];
            
            NSError* error;
            NSDictionary* findAll = @{};
            NSDictionary* onlyDateUpdated = @{@"$fields":@{@"dateUpdated": @1}};
            
            if (collection) {
                NSArray* results = [jb findObjectsWithQuery:findAll hints:onlyDateUpdated inCollection:collection error:&error];
                
                for(NSDictionary* nextObj in results) {
                    NSString* dateUpdated = [nextObj objectForKey:@"dateUpdated"];
                    NSDate *date = [[NSDate alloc] init];
                    
                    date = [dateFormatter dateFromString:dateUpdated];
                    if([maxDate compare: date] == NSOrderedAscending) {
                        maxDate = date;
                    }
                    
                }
                
            }
        }
        
        CDVPluginResult* result = nil;
        // If there are no dates in the collection this will happen, and I don't want us to save this date.
        if([maxDate isEqualToDate: earliest]) {
            result = [CDVPluginResult
                                       resultWithStatus:CDVCommandStatus_ERROR];
            
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
        else {
            result = [CDVPluginResult
                      resultWithStatus:CDVCommandStatus_OK
                      messageAsString: [dateFormatter stringFromDate: maxDate]];
            
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
        return result;
    }
}
- (CDVPluginResult*) saveObjects:(CDVInvokedUrlCommand*)command {
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

        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_ERROR];
        
        if (collection && objectData && jsonDict && jsonArr && [collection saveObjects: jsonArr]) {
            
            result = [CDVPluginResult
                      resultWithStatus:CDVCommandStatus_OK];
            [self success:result callbackId:callbackId];
        }
        else {
            [self error:result callbackId:callbackId];
        }
        
        
        return result;
    }
}


- (CDVPluginResult*) saveObject:(CDVInvokedUrlCommand*)command {
    @synchronized(self) {
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
        
        if (collection && objectData && jsonDict && [collection saveObject: jsonDict]) {
            
            result = [CDVPluginResult
                      resultWithStatus:CDVCommandStatus_OK];
            [self success:result callbackId:callbackId];
        }
        else {
            [self error:result callbackId:callbackId];
        }
        
        
        return result;
    }
}

- (CDVPluginResult*) find:(CDVInvokedUrlCommand*)command {
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

        
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_ERROR];
        
        if (collection && objectData && jsonDict) {
            NSArray* results = [jb findObjectsWithQuery:jsonDict hints:hintDict inCollection:collection error:&error];
            
            NSMutableDictionary *postDict = [[NSMutableDictionary alloc]init];
            [postDict setValue:results forKey:@"results"];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postDict options:0 error:nil];
            NSData* zippedData = [jsonData gzippedData];
            NSString* base64Encoded = [zippedData base64EncodedStringWithOptions:0];
            
            if(!jsonData) {
                [self error:result callbackId:callbackId];
                return result;
            }
            
            result = [CDVPluginResult
                      resultWithStatus:CDVCommandStatus_OK
                      messageAsString: base64Encoded];

            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
        else {
            [self error:result callbackId:callbackId];
        }
        
        return result;
    }
}

- (CDVPluginResult*) remove:(CDVInvokedUrlCommand*)command {
    @synchronized(self) {
        NSString* callbackId = [command callbackId];
        
        NSString* name = [[command arguments] objectAtIndex:0];
        NSString* uid = [[command arguments] objectAtIndex:1];
        
        // Find collection by the name handle.
        EJDBCollection *collection = (EJDBCollection*)[collectionHandles objectForKey: name];
        
        NSError* error;

        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_ERROR];
        
        if (collection && [collection removeObjectWithOID:uid]) {
            result = [CDVPluginResult
                      resultWithStatus:CDVCommandStatus_OK];
            [self success:result callbackId:callbackId];
        }
        else {
            [self error:result callbackId:callbackId];
        }
        
        return result;
    }
}

- (CDVPluginResult*) count:(CDVInvokedUrlCommand*)command {
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

        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_ERROR];

        if (collection && objectData && jsonDict) {
            EJDBQuery* query = [jb createQuery:jsonDict hints:hintDict forCollection:collection];

            uint32_t numResults = [query fetchCountWithError:&error];

            result = [CDVPluginResult
                      resultWithStatus:CDVCommandStatus_OK
                      messageAsInt: numResults];

            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
        else {
            [self error:result callbackId:callbackId];
        }

        return result;

    }
}

@end
