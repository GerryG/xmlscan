# encoding: UTF-8

require 'xmlscan/processor'

ARGV.each do |a|
  pairs = XMLScan::XMLProcessor.process(a, {:key=>:name, :element=>:card, :extras=>[:type]})
  STDOUT << "Result\n"
  STDOUT << pairs.map do |p| n,o,c,t = p
      "#{c&&c.size>0&&"#{c}::"||''}#{n}#{t&&"[#{t}]"}=>#{o*''}"
    end * "\n"
  STDOUT << "\nDone\n"
end
