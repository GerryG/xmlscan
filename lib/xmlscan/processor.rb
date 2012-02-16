# encoding: UTF-8
require 'xmlscan/parser'
require 'xmlscan/visitor'

module XMLScan
  module ElementProcessor
    include XMLScan::Visitor

    SKIP = [:on_chardata, :on_stag, :on_etag, :on_attribute, :on_attr_entityref,
      :on_attr_value, :on_start_document, :on_end_document, :on_attribute_end,
      :on_stag_end, :on_stag_end_empty, :on_attr_charref, :on_attr_charref_hex]

    MY_METHODS = XMLScan::Visitor.instance_methods.to_a - SKIP

    def initialize(opts={}, mod=nil)
      raise "No module" unless mod
      STDERR << "init Element Processer #{mod}\n"
      (MY_METHODS - mod.instance_methods).each do |i|
        self.class.class_eval %{def #{i}(d, *a) d&&(@out << d) end}, __FILE__, __LINE__
      end
      self.class.send :include, mod

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

  end

  class XMLProcessor
    include ElementProcessor

    def self.process(io, opts={}, mod=nil)
      mod ||= ElementProcessing
      STDERR << "process #{io.inspect}, #{opts.inspect}\n"
      io = case io
          when String; open(io)
          when IO, StringIO; io
          else raise "bad type file input #{io.inspect}"
        end

      visitor = new(opts, mod)
      visitor.parser.parse(io)
      visitor.pairs
    end
  end


  module ElementProcessing
    def on_chardata(s) @out << s end
    def on_stag_end(name, s, h, *a)
      if name.to_sym == @element
        # starting a new context, first output our substitute string
        key= h&&h[@key.to_s]||'*no-name*'
        @tmpl = ":transclude|{{:name}}" # def: "{{:key}}"
        STDERR << "templ #{@tmpl.inspect}\n"
        #STDERR << "x> #{x.inspect}, #{h.inspect}, #{(!(/:\w[\w\d]*/ =~ x)) || h[$&[1..-1].to_s] }\n"
        sub =
          @tmpl.split('|').find {|x| !(/:\w[\w\d]*/ =~ x) ||
          h[$&[1..-1].to_s] }.gsub(/:\w[\w\d]*/) {|m|
            STDERR << "templ sub match #{m.inspect}, #{h[m[1..-1]]}\n"
            h[m[1..-1]] }
        #sub = h['transclude'] || "{{#{key}}}"
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

        key= h&&h[@key.to_s]||'*no-name*'
        ex = @extras.map {|e| h[e]}
        @pairs << [key, [], @context, *ex]
      else @out << s end
    end

    attr_reader :pairs, :parser
  end

end
ARGV.each do |a|
  pairs = XMLScan::XMLProcessor.process(a, {:key=>:name, :element=>:card, :extras=>[:type]}, XMLScan::ElementProcessing)
  STDOUT << "Result\n"
  STDOUT << pairs.map do |p| n,o,c,t = p
      "#{c&&c.size>0&&"#{c}::"||''}#{n}#{t&&"[#{t}]"}=>#{o*''}"
    end * "\n"
  STDOUT << "\nDone\n"
end
