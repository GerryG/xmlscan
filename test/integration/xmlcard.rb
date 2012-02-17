# encoding: UTF-8

require 'xmlscan/processor'

ARGV.each do |a|
  pairs = XMLScan::XMLProcessor.process(a, {:key=>:name, :element=>:card,
            :extras=>[:type], :substitute=>':transclude|{{:name}}'})
  STDOUT << "Result\n"
  STDOUT << pairs.map do |p| n=p[0]; o,c,t = p[1]
      "#{c&&c.size>0&&"#{c}::"||''}#{n}#{t&&"[#{t}]"}=>#{o*''}"
    end * "\n"
  STDOUT << "\nDone\n"
end
