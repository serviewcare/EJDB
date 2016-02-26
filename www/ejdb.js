/*global cordova, module*/

module.exports = {
    createDatabaseWithPath: function (path, successCallback, errorCallback) {
	cordova.exec(successCallback, errorCallback, "EJDBPlugin", "createDatabaseWithPath", [path]);
    },
    initializeCollectionWithName: function(name, successCallback, errorCallback) {
	cordova.exec(successCallback, errorCallback, "EJDBPlugin", "initializeCollectionWithName", [name]);	
    },
    saveObject: function(name, someObject, successCallback, errorCallback) {
	var jsonObj = JSON.stringify(someObject);
	cordova.exec(successCallback, errorCallback, "EJDBPlugin", "saveObject", [name, jsonObj]);	
    },
    find: function(name, query, successCallback, errorCallback) {
	var jsonQuery = JSON.stringify(query);
	cordova.exec(successCallback, errorCallback, "EJDBPlugin", "find", [name, jsonQuery]);		
    },
    remove: function(name, uid, successCallback, errorCallback) {
	cordova.exec(successCallback, errorCallback, "EJDBPlugin", "remove", [name, uid]);	
    }
};
