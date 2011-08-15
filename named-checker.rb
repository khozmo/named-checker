require 'rubygems'
require 'whois'
require 'pp'

#die("please enter path to named.conf file") if defined?(ARGV[0])

if ARGV[0].nil? then
  puts("please enter path to named.conf") 
  exit
end
count = 0
File.open("#{ARGV[0]}").each {|line|
  if line =~ /^zone/ && line !~ /arpa/ then
    begin
      a = Whois.whois("#{line.match(/^zone\ \"(.*)\"/)[1]}")
    rescue Exception
      next
    end
    pp line.match(/^zone\ \"(.*)\"/)[1]
    begin
      a.nameservers.each do |ns|
      puts ns
    end
  rescue
    puts "nameservers failed lookup"
    next
  end
    sleep 10 if line.include?(".org") || line.include?(".gov") 
  count += 1
  pp count
  end
}