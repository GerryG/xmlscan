# encoding: UTF-8

require 'xmlscan/processor'

# need to make these into supplied blocks somehome
module CustomProcessing
  def on_chardata(s) @out << s end
  def on_stag_end(name, s, h, *a)
    if name.to_sym == @element
      # starting a new context, first output our substitute string
      key= h&&h[@key.to_s]||'*no-name*'
      sub = h['transclude'] || "{{#{key}}}"
      @out << sub
      # then push the current context and initialize this one
      @stack.push([@context, @out, *@ex])
      @context = key; @out = []
      @ex = @extras.map {|e| h[e]}
    else @out << s end # pass through tags we aren't processing
  end

  def on_etag(name, s=nil)
    if name.to_sym == @element
      # output a card (name, content, type)
      @pairs << [@context, @out, @stack[-1][0], *@ex]
      # restore previous context from stack
      last = @stack.pop
      @context, @out, @ex = last.shift, last.shift, *last
    else @out << s end
  end

  def on_stag_empty_end(name, s=nil, h={}, *a)
    if name.to_sym == @element
      # I don't think we have this case, but it is simple to add later
      STDERR << "empty card ???: #{name}, #{s}, #{h.inspect}\n"
    else @out << s end
  end

  attr_reader :pairs, :parser
end

ARGV.each do |a|
  pairs = XMLScan::XMLProcessor.process(a, {:key=>:name, :element=>:card, :extras=>[:type]}, CustomProcessing)
  STDOUT << "Result\n"
  STDOUT << pairs.map do |p| n,o,c,t = p
      "#{c&&c.size>0&&"#{c}::"||''}#{n}#{t&&"[#{t}]"}=>#{o*''}"
    end * "\n"
  STDOUT << "\nDone\n"
end
