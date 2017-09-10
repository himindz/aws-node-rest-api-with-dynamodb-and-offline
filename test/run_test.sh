#!/bin/bash
for f in test/todo*.rb; do ruby $f; done
ruby test/parse.rb lambda.out >lambda.csv
ruby test/generate_graph.rb lambda.csv serverless.yml
