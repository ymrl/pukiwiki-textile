#!/usr/bin/env ruby
require 'redcloth'
source = ""
if ARGV[0]
  File::open(ARGV[0]).each{|line| source +=line}
else
  while line =gets
    source += line
  end
end

puts <<EOD
<!DOCTYPE html>
<html>
<head>
</head>
<body>
EOD
puts RedCloth.new(source).to_html
puts <<EOD
</body>
</html>
EOD
