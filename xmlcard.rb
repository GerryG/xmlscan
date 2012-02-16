# encoding: UTF-8
require 'xmlscan/parser'
require 'xmlscan/visitor'

module MyVisitor
  module ElementProcessor
    include XMLScan::Visitor

    SKIP = [:on_chardata, :on_stag, :on_etag, :on_attribute, :on_attr_entityref,
      :on_attr_value, :on_start_document, :on_end_document, :on_attribute_end,
      :on_stag_end, :on_stag_end_empty, :on_attr_charref, :on_attr_charref_hex]

    MY_METHODS = XMLScan::Visitor.instance_methods.to_a - SKIP
    MY_METHODS.each do |i|
      class_eval %{def #{i}(d, *a) d&&(@out << d) end}, __FILE__, __LINE__
    end

    def initialize(opts={})
      @element = opts[:element] || raise("need an element")
      @key = opts[:key] || raise("need a key")
      @extras = (ex = opts[:extras]) ? ex.map(&:to_sym) : []

      @pairs = []    # output [name, content, value] * 1 or more
      @context = ''  # current key(name) of the element (card)
      @stack = []    # stack of containing context cards
      @out = []      # current output for name(card)
      @parser = XMLScan::XMLParser.new(self)
      self
    end

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

  class MyProcessor
    include ElementProcessor

    def self.process(file, opts={})
      raise "Not readable #{file.inspect}" unless IO===( io =
                                             IO===file ? file : open(file) )
      visitor = new(opts)
      visitor.parser.parse(io)
      visitor.pairs
    end
  end

end

ARGV.each do |a|
  pairs = MyVisitor::MyProcessor.process(a, {:key=>:name, :element=>:card, :extras=>[:type]})
  STDOUT << "Result\n"
  STDOUT << pairs.map do |p| n,o,c,t = p
      "#{c&&c.size>0&&"#{c}::"||''}#{n}#{t&&"[#{t}]"}=>#{o*''}"
    end * "\n"
  STDOUT << "\nDone\n"
end
