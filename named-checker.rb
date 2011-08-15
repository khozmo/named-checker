#!/usr/bin/env ruby

require 'rubygems'
require 'whois'
require 'pp'

if ARGV[0].nil? then
  puts("please enter path to named.conf") 
  exit
end

count = 0
output_file = File.new("named-output.csv", "w")

File.open("#{ARGV[0]}").each {|line|
  if line =~ /zone / && line !~ /arpa/ then
    domain_name =  /zone\ "(.*)"/.match(line).to_a
    puts count += 1
    csv = []
    begin
      a = Whois.whois("#{domain_name[1]}")
    rescue Exception => e
      puts e.message
      pp domain_name[1]
      pp line
      csv << domain_name[1]+","+e.message
      output_file.puts csv.join(",")
      next
    end
    
    csv << domain_name[1]
    
    if  a.registered? then
      begin
        a.nameservers.each {|ns| csv << ns[0]}
      rescue
        csv << "failed lookup"
        output_file.puts csv.join(",")
        next
      end
    else
      csv << "no longer registered"
      output_file.puts csv.join(",")
      next
    end
  
    sleep 20 if line.include?(".org") || line.include?(".gov") 
    output_file.puts csv.join(",")
  end
}
output_file.close
