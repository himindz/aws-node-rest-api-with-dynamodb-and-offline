'use strict';
var fs = require('fs');
let todos = JSON.parse(fs.readFileSync('./offline/migrations/todos.json', 'utf8'));
const AWS = require('aws-sdk'); // eslint-disable-line import/no-extraneous-dependencies

let options = {};

// connect to local DB if running offline
  options = {
    region: 'localhost',
    endpoint: 'http://localhost:8000',
  };

const client = new AWS.DynamoDB(options);
client.createTable(todos.Table, function(err, data) {
  if (err) {
    console.log("Error", err);
  } else {
    console.log("Success");
  }
});