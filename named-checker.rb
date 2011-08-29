#!/usr/bin/env ruby

require 'rubygems'
require 'whois'
require 'pp'
require 'mail'

if ARGV.empty? then
  puts("usage: ./named-checker.rb [path to config file]") 
  exit
end

files_to_zip =[]

ARGV.each { |zone_file|   
count = 0
output_file = File.new("#{zone_file.gsub('.','-')}.csv", "w")
files_to_zip << output_file

File.open(zone_file).each {|line|
  if line =~ /^zone / && line !~ /arpa/ then
    domain_name =  line.match(/zone\ "(.*)"/)[1]
#    puts domain_name
#    puts count += 1
    csv = []
    begin
      a = Whois.whois(domain_name)
    rescue Exception => e
      puts e.message
      pp domain_name
      pp line
      csv << domain_name+","+e.message
      output_file.puts csv.join(",")
      next
    end
    
    servers =[]
    if a.registered? then
      begin
        a.nameservers.each {|ns| servers << ns[0].downcase}
      rescue
        output_file.puts ("#{domain_name}, failed lookup")
        next
      end
    else
      output_file.puts ("#{domain_name}, no longer registered")
      next
    end
  
    sleep 20 if line.include?(".org") || line.include?(".gov")
    output_file.puts ("#{domain_name},#{servers.sort.join(",")}")
  end
}
output_file.close
}

