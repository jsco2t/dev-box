#!/usr/bin/env ruby

# this is mostly a "bookmark" cause I keep forgetting the command
# for this - so this script will remember for me :)

if ARGV[0] == nil
  raise 'First argument must be a file path to file which to generate a checksum for.'
else
  puts "Generating checksum for #{ARGV[0]}"
end

puts `md5 "#{ARGV[0]}"`
