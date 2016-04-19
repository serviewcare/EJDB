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
    saveObjects: function(name, someObjects, successCallback, errorCallback) {
        var jsonObj = JSON.stringify({ns: someObjects});
        cordova.exec(successCallback, errorCallback, "EJDBPlugin", "saveObjects", [name, jsonObj]);
    },
    find: function(name, query, hints, successCallback, errorCallback) {
        var jsonQuery = JSON.stringify(query);
        var jsonHints = JSON.stringify(hints);
        cordova.exec(successCallback, errorCallback, "EJDBPlugin", "find", [name, jsonQuery, jsonHints]);
    },
    remove: function(name, uid, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "EJDBPlugin", "remove", [name, uid]);	
    },
    count: function(name, query, hints, successCallback, errorCallback) {
        var jsonQuery = JSON.stringify(query);
        var jsonHints = JSON.stringify(hints);
        cordova.exec(successCallback, errorCallback, "EJDBPlugin", "count", [name, jsonQuery, jsonHints]);
    },
    setIndexOption: function(name, option, fieldPath, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "EJDBPlugin", "setIndexOption", [name, option, fieldPath]);
    }
};
