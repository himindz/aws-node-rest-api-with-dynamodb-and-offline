#!/bin/bash
export AWS_ACCESS_KEY_ID=ACCESS
export AWS_SECRET_ACCESS_KEY=ALLOWED
export AWS_REGION=us-east-1
echo 'starting lambda emulator'
npm run sls:lambda >lambda.out &
sleep 10s
echo 'starting serverless simulator'
npm run sls:simulate >simulate.out&
sleep 10s
npm run sls:seed