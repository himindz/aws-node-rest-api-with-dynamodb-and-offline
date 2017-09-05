require 'fileutils'
EMPTYLINE = /- -/
START_REQUEST= /START RequestId:\s(.*) Version:\s(.*)/
REPORT_REQUEST= /REPORT RequestId:\s(.*)/
RESOURCE_PATH= /".*handler":"(.*)","runtime".*/
REPORT_DATA= /([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\s+Duration:\s(\d+.\d+)\sms\s+Billed Duration:\s(\d+)\sms\s+Memory Size:\s(\d+)\sMB\s+Max Memory Used:\s(\d+)\sMB/
current_request='NONE'
current_resource='NONE'
current_report='NONE'
puts "url,request_id,duration,billed_duration,total_memory,memory_used"
File.foreach(ARGV[0]) do |line|
    next if line.match(EMPTYLINE)
    line.gsub(/[^[:print:]]/i, '')
    if (current_request.match('NONE'))
      start_request = line.match(START_REQUEST)
      next unless start_request
      unless start_request[2].match('\$LATEST\\\u')
        current_request = start_request[1]
      end
      next
    end
    if (current_resource.match('NONE'))
      resource_path = line.match(RESOURCE_PATH)
      next unless resource_path
      current_resource = resource_path[1]
      next
    end
    if (current_report.match('NONE'))
      report_request = line.match(REPORT_REQUEST)
      next unless report_request
      current_report = report_request[1]
      report_data = current_report.match(REPORT_DATA)
    end
    puts "#{current_resource},#{current_request},#{report_data[2]},#{report_data[3]},#{report_data[4]},#{report_data[5]}"
    current_request='NONE'
    current_resource='NONE'
    current_report='NONE'
    report_data='NONE'
end
