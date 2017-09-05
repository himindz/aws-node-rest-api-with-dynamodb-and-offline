require 'ruby-jmeter'
test do
  header [
    { name: 'Content-Type', value: 'application/json' }
  ]
  threads count: 1, loops: 100, scheduler: false do
    get name: 'Get /todos', url: 'http://localhost:3000/todos'
  end
  
end.run( jtl: 'todos_list.jtl')
