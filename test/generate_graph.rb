require 'csv'
require 'gruff'
require 'base64'
require 'erb'
require 'yaml'


serverless = YAML.load_file(ARGV[1])
duration = Hash.new
memory = Hash.new
billed_duration = Hash.new
graphs = Hash.new


def get_template()
  %{
    <html>
      <head>
        <style type="text/css">
            table.gridtable {
              font-family: verdana,arial,sans-serif;
              font-size:11px;
              color:#333333;
              border-width: 1px;
              border-color: #666666;
              border-collapse: collapse;
            }
            table.gridtable th {
              border-width: 1px;
              padding: 8px;
              border-style: solid;
              border-color: #666666;
              background-color: #dedede;
            }
            table.gridtable td {
              border-width: 1px;
              padding: 8px;
              border-style: solid;
              border-color: #666666;
              background-color: #ffffff;
            }
        </style>
      </head>
      <body>
        <h1> AWS Lambda Function Benchmark Results for <%= @function_name %></h1>
        <table class="gridtable">
          <tr>
            <td>End Points Benchmarked</td>
            <td><%= total_end_points %></td>
          </tr>
          <tr>
            <td>Function Memory Size</td>
            <td><%= function_memory_size %>MB</td>
          </tr>  
          <tr>
            <td>Average Bill Duration (Based on <%= total_executions %> executions)</td>
            <td><%= average_execution_time %>ms</td>
          </tr>
          <tr>
            <td>Request Charges (Based on 30 million Request per month)</td>
            <td>$<%= request_charges %></td>
          </tr>
          <tr>
            <td>Compute Charges (Based on 30 million Requests per month)</td>
            <td>$<%= compute_charges %></td>
          </tr>    
        </table>  

        <% @graphs.each do |name, data| %>
           <h2><%= name %></h2><br/>
           <table class="gridtable">
              <tr>
                  <th>End Point</th><th>Min</th><th>Max</th><th>Average</th>
              </tr>
              <% data.each do |key, graph_data| %>
                 <tr>
                    <td><%= key %></td><td><%= graph_data['data'].min%></td><td><%= graph_data['data'].max%></td><td><%= (graph_data['data'].inject{ |sum, el| sum + el }.to_f / graph_data['data'].size).round(2)%></td>
                 </tr>
              <% end %> 
           </table><br/>
           <% data.each do |key,graph_data| %>
              <img src="data:image/png;base64,<%=graph_data['image']%>"/>
           <% end %> 
        <% end %>
      </body>
    </html>  
  }
end
def nearest_multiple_of_64 number
  return 128 if number <= 128
  (number/64).ceil * 64
end

class ReportGenerator
  include ERB::Util

  attr_accessor :graphs, :template, :function_name, :memory_needed, :total_executions, :average_execution_time, :request_charges, :compute_charges, :compute_ms100, :gb_seconds, :total_end_points, :function_memory_size 

  def initialize(graphs, template,function_name)
    aws_prices = {
      "128" =>	{ "free"=>3200000,"price"=>0.000000208},
      "192" =>	{ "free"=>2133333,"price"=>0.000000313},
      "256" =>	{ "free"=>1600000,"price"=>0.000000417},
      "320" =>	{ "free"=>1280000,"price"=>0.000000521},
      "384" =>	{ "free"=>1066667,"price"=>0.000000625},
      "448" =>	{ "free"=>914286,"price"=>0.000000729},
      "512" =>	{ "free"=>800000,"price"=>0.000000834},
      "576" =>	{ "free"=>711111,"price"=>0.000000938},
      "640" =>	{"free"=>640000,"price"=>0.000001042},
      "704" =>	{"free"=>581818,"price"=>0.000001146},
      "768" =>	{"free"=>533333,"price"=>0.000001250},
      "832" =>	{"free"=>492308,"price"=>0.000001354},
      "896" =>	{"free"=>457143,"price"=>0.000001459},
      "960" =>	{"free"=>426667,"price"=>0.000001563},
      "1024" =>	{"free"=>400000,"price"=>0.000001667},
      "1088" =>	{"free"=>376471,"price"=>0.000001771},
      "1152" =>	{"free"=>355556,"price"=>0.000001875},
      "1216" =>	{"free"=>336842,"price"=>0.000001980},
      "1280" =>	{"free"=>320000,"price"=>0.000002084},
      "1344" =>	{"free"=>304762,"price"=>0.000002188},
      "1408" =>	{"free"=>290909,"price"=>0.000002292},
      "1472" =>	{"free"=>278261,"price"=>0.000002396},
      "1536" =>	{"free"=>266667,"price"=>0.000002501}
    }
    @graphs = graphs
    @template = template
    @function_name = function_name
    @total_executions = 0
    billed_execution = Array.new
    memory = Array.new
    graphs['Billed Duration'].each { |key, graph|
       billed_execution.push(*graph['data'])
    }
    @total_executions = billed_execution.size()
    graphs['Memory'].each { |key, graph|
       memory.push(*graph['data'])
    }
    @memory_needed = memory.max
   
    @function_memory_size = nearest_multiple_of_64 @memory_needed
    puts @function_memory_size

    @average_execution_time = (billed_execution.inject{ |sum, el| sum + el }.to_f / billed_execution.size()).round(-2)
    @request_charges = 30*0.20
    @compute_ms100 = (@average_execution_time/100)*30000000
    @compute_charges = aws_prices[@function_memory_size.to_s]['price']*@compute_ms100
    @total_end_points = graphs['Memory'].keys.length
    puts "Function Memory Size: #{@function_memory_size}"
    puts "Max Memory Needed:  #{@memory_needed}"
    puts "Average Execution Time: #{@average_execution_time}"
    puts "Compute 100 ms: #{@compute_ms100}"
    puts "Lambda Price: #{'%.09f' % aws_prices[@function_memory_size.to_s]['price']}"
    puts "Request Charges: #{'%.02f' % @request_charges} "
    puts "Compute Charges:  #{'%.02f' % @compute_charges}"
    puts "Total Executions: #{@total_executions}"
    puts "Total End Points: #{@total_end_points}"
    
  end
  def render()
    ERB.new(@template).result(binding)    
  end
  def save(file)
    File.open(file, "w+") do |f|
      f.write(render)
    end
  end
end  

def generate_graph(gname, name,data)
  graph = Gruff::Line.new('400x200')
  graph.title = "#{gname}"
  graph.data(name, data)
  graph_fname= "#{gname}_#{name.gsub('/','_')}"
  graph.write("#{graph_fname}.png")
  encoded_string = Base64.encode64(File.open("#{graph_fname}.png", "rb").read)
  return encoded_string
end
CSV.foreach(ARGV[0], :headers => true) do |row|
    if duration[row[0]].nil?
       duration[row[0]] = Array.new
    end
    duration[row[0]].push(row[2].to_f)

    if billed_duration[row[0]].nil?
       billed_duration[row[0]] = Array.new
    end
    billed_duration[row[0]].push(row[3].to_f)
    if memory[row[0]].nil?
       memory[row[0]] = Array.new
    end
    memory[row[0]].push(row[5].to_f)

end
graphs['Duration'] = Hash.new
graphs['Billed Duration'] = Hash.new
graphs['Memory'] = Hash.new

duration.each { |key,array|
   graphs["Duration"][key] = Hash.new
   graphs["Duration"][key]['data']=array
   graphs["Duration"][key]['image']=generate_graph("Duration", key, array)  
}
billed_duration.each { |key,array|
graphs["Billed Duration"][key] = Hash.new
graphs["Billed Duration"][key]['data']=array
graphs["Billed Duration"][key]['image']=generate_graph("Billed Duration", key, array) 
}
memory.each { |key,array|
graphs["Memory"][key] = Hash.new
graphs["Memory"][key]['data']=array
graphs["Memory"][key]['image']=generate_graph("Memory", key, array)  
}
report_generator = ReportGenerator.new(graphs, get_template,serverless['service'])
report_generator.save("report.html")
