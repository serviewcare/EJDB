#import <Foundation/Foundation.h>
#include "tcejdb/ejdb.h"
#import "EJDBCollection.h"

@class EJDBQuery;

typedef NS_OPTIONS(int, EJDBOpenModes)
{
    /** EJDBOpenReader - Open as a reader. */
    EJDBOpenReader = 1 << 0,
    /** EJDBOpenWriter - Open as a writer. */
    EJDBOpenWriter = 1 << 1,
    /** EJDBOpenCreator - Create if db file does not exist. */
    EJDBOpenCreator = 1 << 2,
    /** EJDBOpenTruncator - Truncate db on open. */
    EJDBOpenTruncator = 1 << 3,
    /** EJDBOpenWithoutLock - Open without locking. */
    EJDBOpenWithoutLock = 1 << 4,
    /** EJDBOpenWithoutBlocking - Lock without blocking. */
    EJDBOpenWithoutBlocking = 1 << 5,
    /** EJDBOpenSynchronize - Synchronize every transaction. */
    EJDBOpenSynchronize = 1 << 6
};

typedef NS_OPTIONS(int, EJDBImportOptions)
{
    /** EJDBImportUpdate - Update existing collection entries with imported ones. Collections will not be recreated and its options are ignored. */
    EJDBImportUpdate = 1 << 1,
    /** EJDBImportReplace - Recreate existing collections and replace all collection data with imported entries. */
    EJDBImportReplace = 1 << 2
};

/** Transaction block definition. Used for executing statements in transaction. 
 @return YES - if you'd like to commit the transaction. NO - if you'd like to abort it.
 */
typedef BOOL(^EJDBTransactionBlock)(EJDBCollection *collection, NSError **error);

/**
 This class wraps the EJDB object and provides the ability to manipulate the underlying db,collections,etc.
*/
@interface EJDBDatabase : NSObject

/** The underlying EJDB object. */
@property (assign,nonatomic,readonly) EJDB *db;

/** 
 Initializes the object with the path of the db.
 @param path - The full path of where the database will reside excluding the database file name.
 @param fileName - The file name (without path) of the database file.
 @brief - The fileName is appended to path. If the path does not exist it is created.
 @since - v0.1.0
*/
- (id)initWithPath:(NSString *)path dbFileName:(NSString *)fileName;
/** 
 Opens the database in reader, writer and create mode.
 @param error - The error object. Pass a NULL if not interested in retrieving the possible error.
 @returns - YES if successful. NO if an error occurred.
 @since - v0.1.0
*/
- (BOOL)openWithError:(NSError **)error;
/**
 Opens the database in the specified mode.
 @param mode - The desired mode the db should be opened with. Please see ejdb.h for more information about modes.
 @param error - The error object. Pass a NULL if not interested in retrieving the possible error.
 @returns - YES if successful. NO if an error occurred.
 @since - v0.1.0
*/
- (BOOL)openWithMode:(EJDBOpenModes)mode error:(NSError **)error;
/**
 Check if the database is open or not.
 @returns - YES if open. NO if not.
 @since - v0.1.0
*/
- (BOOL)isOpen;
/**
 Gets a dictionary of data about the database such as collections and their respective indexes, options,etc.
 @since - v0.1.0
*/
- (NSDictionary *)metadata;
/**
 Get a list of the collection's names in the database.
 @param - Array of collection names.
 @since - v0.1.0
*/
- (NSArray *)collectionNames;
/**
 Fetches a collection with the name provided.
 @param name - The name of the collection.
 @returns - The EJDBCollection object or nil if the collection does not exist in the db.
 @since - v0.1.0
*/
- (EJDBCollection *)collectionWithName:(NSString *)name;
/** 
 Fetches a list of EJDBCollection objects that exist and are currently open.
 @returns - Array of EJDBCollection objects or nil if there was an error.
 @since - v0.1.0
*/
- (NSArray *)collections;
/**
 Creates the collection with the name provided and default collection options.
 @param name - The desired name of the collection.
 @param error - The error object. Pass a NULL if not interested in retrieving the possible error.
 @returns - The EJDBCollection object or nil if the collection could not be created.
 @since - v0.1.0
*/
- (EJDBCollection *)ensureCollectionWithName:(NSString *)name error:(NSError **)error;
/**
 Creates the collection with the name and collection options provided.
 @param name - The desired name of the collection.
 @param options - The desired collection options. Please see ejdb.h for more infomration about collection options.
 @param error - The error object. Pass a NULL if not interested in retrieving the possible error.
 @returns - The EJDBCollection object or nil if the collection could not be created.
 @since - v0.1.0
*/
- (EJDBCollection *)ensureCollectionWithName:(NSString *)name options:(EJDBCollectionOptions *)options error:(NSError **)error;
/**
 Removes the collection from the db with the provided name and the associated db files/indexes.
 @param name - The name of the collection to remove.
 @returns - YES if removal succeeded. NO if not.
 @since - v0.1.0
*/
- (BOOL)removeCollectionWithName:(NSString *)name;
/**
 Removes the collection from the db with the provided name with the option of removing associated db files/indexes.
 @param name - The name of the collection to remove.
 @param unlinkFile - Pass YES if you want associated db files/indexes to removed. NO if not.
 @returns - YES if removal succeeded. NO if not.
 @since - v0.1.0
*/
- (BOOL)removeCollectionWithName:(NSString *)name unlinkFile:(BOOL)unlinkFile;
/**
 Finds all objects that match the criteria passed in the query object but with no query hints.
 Please look at ejdb.h for more info on queries and query hints.
 
 @param query - The query dictionary.
 @param collection - The collection to query.
 @param error - The error object. Pass a NULL if not interested in retrieving the possible error.
 @returns - Array of objects matching the criteria or nil if there was an error.
 @since - v0.1.0
*/
- (NSArray *)findObjectsWithQuery:(NSDictionary *)query inCollection:(EJDBCollection *)collection error:(NSError **)error;
/**
 Finds all objects that match the criteria passed in the query and query hints.
 Please look at ejdb.h for more info on queries and query hints.
 
 @param query - The query dictionary.
 @param hints - The query hints.
 @param collection - The collection to query.
 @param error - The error object. Pass a NULL if not interested in retrieving the possible error.
 @returns - Array of objects matching the criteria or nil if there was an error.
 @since - v0.1.0
*/
- (NSArray *)findObjectsWithQuery:(NSDictionary *)query hints:(NSDictionary *)queryHints inCollection:(EJDBCollection *)collection
                            error:(NSError **)error;
/**
 Finds all objects sthat match the criteria passed in the query builder.
 Please look at ejdb.h for more info on queries and query hints.
 @param queryBuilder - An object that implements the EJDBQueryBuilderDelegate protocol such as EJDBQueryBuilder or EJDBFIQueryBuilder.
 @param collection - The collection to query.
 @param error - The error object. Pass a NULL if not interested in retrieving the possible error.
 @returns - Array of objects matching the criteria or nil if there was an error.
 @since - v0.5.0
*/
- (NSArray *)findObjectsWithQueryBuilder:(id<EJDBQueryBuilderDelegate>)queryBuilder inCollection:(EJDBCollection *)collection error:(NSError **)error;
/**
 Create a query with the provided dictionary and hints. This method doesn't actually fetch the objects, it only creates the query for later fetching.
 Please look at ejdb.h for more info on queries and query hints.
 
 @param query - The query dictionary.
 @param hints - The hints dictionary, pass a NULL if not interested in giving query hints.
 @param collection - The collection to create the query for.
 @returns - The EJDBQuery ready for fetching.
 @since - v0.2.0
*/
- (EJDBQuery *)createQuery:(NSDictionary *)query hints:(NSDictionary *)queryHints forCollection:(EJDBCollection *)collection;

/**
 Create a query with the provided query builder. This method doesn't actually fetch the objects, it only creates the query for later fetching.
 Please look at ejdb.h for more info on queries and query hints.
 @param queryBuilder - An object that implements the EJDBQueryBuilderDelegate protocol such as EJDBQueryBuilder or EJDBFIQueryBuilder.
 @param collection - The collection to create the query for.
 @returns - The EJDBQuery ready for fetching.
 @since - v0.5.0
*/
- (EJDBQuery *)createQueryWithBuilder:(id<EJDBQueryBuilderDelegate>)queryBuilder forCollection:(EJDBCollection *)collection;

/**
 Executes the statements by the provided EJDBTransactionBlock as a transaction.
 The block gives you access to the EJDBCollection specified in the collection argument.
 The block must return either a YES, if you'd like to commit the transaction or NO if you'd like to abort it.
 
 @param collection - The collection the transaction will occur in.
 @param transaction - The EJDBTransactionBlock, this is where you do your work that is enclosed in a transaction.
 @since - v0.1.0
*/
- (BOOL)transactionInCollection:(EJDBCollection *)collection error:(NSError **)error transaction:(EJDBTransactionBlock)transaction;
/**
 Export collections from provided collection names array to a specified directory.
 @param collections - The array of names of the collections to be exported.
 @param path - The directory path to which the collections should be exported.
 @param asJSON - YES, if you'd like the collections to be exported as JSON. NO, if you want them exported as BSON.
 Note: You can only import collections that were exported in BSON format!
 @returns - YES if successful. NO if not.
 @since - v0.3.0
*/
- (BOOL)exportCollections:(NSArray *)collections toDirectory:(NSString *)path asJSON:(BOOL)asJSON;
/**
 Export all collections.
 @param path - The directory path to which the collections should be exported.
 @param asJSON - YES, if you'd like the collections to be exported as JSON. NO, if you want them exported as BSON.
 Note: You can only import collections that were exported in BSON format!
 @returns - YES if successful. NO if not.
 @since - v0.3.0
*/
- (BOOL)exportAllCollectionsToDirectory:(NSString *)path asJSON:(BOOL)asJSON;
/**
 Import collections from provided collection names array from a specified directory.
 @param collections - The array of names of the collections to be imported.
 @param path - The directory path from which to import.
 @param options - The options that can be supplied that affect import. See ::EJDBImportOptions for possible options.
 @returns - YES if successful. NO if not.
 @since - v0.3.0
*/
- (BOOL)importCollections:(NSArray *)collections fromDirectory:(NSString *)path options:(EJDBImportOptions)options;
/**
 Import all collections from a specified directory.
 @param path - The directory path from which to import.
 @param options - The options that can be supplied that affect import. See ::EJDBImportOptions for possible options.
 @returns - YES if successful. NO if not.
 @since - v0.3.0
*/
- (BOOL)importAllCollectionsFromDirectory:(NSString *)path options:(EJDBImportOptions)options;
/**
 Populate the provided error object.
 @since - v0.1.0
*/
- (void)populateError:(NSError **)error;
/** 
 Close the database.
 @since - v0.1.0 
*/
- (void)close;

@end