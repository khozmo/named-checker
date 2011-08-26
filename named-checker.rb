#!/usr/bin/env ruby

require 'rubygems'
require 'whois'
require 'pp'

if ARGV[0].nil? then
  puts("usage: ./named-checker.rb [path to config file]") 
  exit
end

count = 0
output_file = File.new("#{ARGV[0].gsub('.','-')}.csv", "w")

File.open("#{ARGV[0]}").each {|line|
  if line =~ /^zone / && line !~ /arpa/ then
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
    
    #csv << domain_name[1]
    servers =[]
    if  a.registered? then
      begin
        a.nameservers.each {|ns| servers << ns[0].downcase}
      rescue
        #csv << "failed lookup"
        output_file.puts ("#{domain_name[1]}, failed lookup")
        next
      end
    else
      #csv << "no longer registered"
      output_file.puts ("#{domain_name[1]}, no longer registered")
      next
    end
  
    sleep 20 if line.include?(".org") || line.include?(".gov")
    puts "#{domain_name[1]} unsorted #{servers}"
    servers.sort!
    puts "#{domain_name[1]} sorted #{servers}"
    output_file.puts ("#{domain_name[1]},#{servers.join(",")}")
  end
}
output_file.close
