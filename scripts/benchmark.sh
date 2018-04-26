#!/bin/bash
mkdir -p report
for f in test/todo*.rb; do ruby $f; done
ruby test/parse.rb lambda.out >report/lambda.csv
cd report
ruby ../test/generate_report.rb ./lambda.csv ../serverless.yml
