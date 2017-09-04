var AWS = require('aws-sdk'),
dm = require("dynamodb-migrations");
var options = { region: 'us-east-1', endpoint: "http://172.17.0.1:8000" },
     dynamodb = {raw: new AWS.DynamoDB(options) , doc: new AWS.DynamoDB.DocumentClient(options) };
dm.init(dynamodb, '/git/offline/migrations'); /* This method requires multiple dynamodb instances with default Dynamodb client and Dynamodb Document Client. All the other methods depends on this. */
dm.execute('todos', { prefix: '', suffix: ''}); /* This executes the 'sampleTable' migration. Note: second parameter is optional. With prefix and suffix actual table name e.g dev-<tablename>-sample */


