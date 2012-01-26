#!/usr/bin/env ruby
require "../lib/pukiwiki-textile"

source = ""
if ARGV[0]
  File::open(ARGV[0]).each{|line| source +=line}
else
  while line = gets
    source += line
  end
end

puts PukiwikiTextile.convert(source)
