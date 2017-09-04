'use strict';

const AWS = require('aws-sdk'); // eslint-disable-line import/no-extraneous-dependencies

let options = {};

// connect to local DB if running offline
  options = {
    region: 'us-east-1',
    endpoint: 'http://172.17.0.1:8000',
  };

const client = new AWS.DynamoDB.DocumentClient(options);

module.exports = client;
