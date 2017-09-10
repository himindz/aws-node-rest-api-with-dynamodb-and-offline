require 'ruby-jmeter'
test do
  header [
    { name: 'Content-Type', value: 'application/json' }
  ]
  threads count: 1, loops: 100, scheduler: false do
    post name: 'Post /todos', url: 'http://localhost:3000/todos',
         raw_body: '{ "text": "Learn Serverless" }'
  end
  
end.run( jtl: 'todos_create.jtl')
