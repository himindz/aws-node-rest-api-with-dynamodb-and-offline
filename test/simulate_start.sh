#!/bin/bash
export AWS_ACCESS_KEY_ID=ACCESS
export AWS_SECRET_ACCESS_KEY=ALLOWED
export AWS_REGION=us-east-1
npm run sls:lambda >lambda.out &
sleep 30s
npm run sls:simulate >simulate.out&
sleep 30s
npm run sls:seed
