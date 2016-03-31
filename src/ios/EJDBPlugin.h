#import <Cordova/CDV.h>

@interface EJDBPlugin : CDVPlugin

- (void) createDatabaseWithPath:(CDVInvokedUrlCommand*)command;
- (void) initializeCollectionWithName:(CDVInvokedUrlCommand*)command;
- (void) saveObject:(CDVInvokedUrlCommand*)command;
- (void) maxDate:(CDVInvokedUrlCommand*)command;
- (void) find:(CDVInvokedUrlCommand*)command;
- (void) remove:(CDVInvokedUrlCommand*)command;
- (void) count:(CDVInvokedUrlCommand*)command;

@end
