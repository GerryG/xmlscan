# encoding: UTF-8

require 'xmlscan/parser'
require 'xmlscan/visitor'

module MyVisitor

  module ElementProcessor

    include XMLScan::Visitor

    def initialize()
      @pairs = []    # output [name, content, value] * 1 or more
      @context = ''  # current key(name) of the element (card)
      @stack = []    # stack of containing context cards
      @out = []      # current output for name(card)
      self
    end

    SKIP = %w{on_chardata on_stag on_attribute on_attr_entityref on_attr_value
      on_start_document on_end_document on_attribute_end
      on_stag_end on_stag_empty_end on_etag}

    XMLScan::Visitor.instance_methods.each { |i|
      #unless instance_methods.member? i
      unless SKIP.member? i.to_s
        STDERR << "defining #{i}\n"
        #STDERR << "data #{i}:\#{args.inspect}\n"
        #STDERR << %{data nil #{i}:\#{caller*"\n"}\n} unless args[1]
        class_eval <<-END, __FILE__, __LINE__ + 1
          def #{i}(*args)
            STDERR << %{data nil #{i}:\#{caller*"\n"}\n} unless args[1]
            @out << args[1] if args[1]
          end
        END
      end
    }

    def on_chardata(s)
      STDERR << "on_cd:#{s}\n"
      @out << s end

    def on_stag_end(name, s, h, *a)
      if name.to_sym == :card
        # starting a new context, first output our substitute string
        key= h&&h['name']||'*no-name*'
        sub = h['transclude'] || "{{#{key}}}"
        @out << sub
        # then push the current context and initialize this one
        @stack.push([@context, @out, @type])
        @context = key; @out = []; @type = h['type']
        STDERR << "sTag: #{sub.inspect} #{@context}, S:#{@stack.inspect}, O:#{@out.inspect}\n" #{caller*"\n"}\n"
      else @out << s end # pass through tags we aren't processing
    end
    def on_stag_empty_end(name, s=nil, h={}, *a)
      if name.to_sym == :card
        # I don't think we have this case, but it is simple to add later
         STDERR << "empty card ???: #{name}, #{s}, #{h.inspect}\n"
      else @out << s end
    end
    def on_etag(name, s=nil)
      if name.to_sym == :card
        # output a card (name, content, type)
        @pairs << [@context, @out, @type]
        #STDERR << "stack[#{@stack.inspect}]\n, #{s}\n"
        STDERR << "eTag to pairs[#{@context}] #{@out.inspect}, #{s}\n"
        # restore previous context from stack
        @context, @out, @type = (@stack.pop)
        STDERR << " pop[#{@context}:#{@type}] #{@out.inspect}\n"
      else @out << s end
    end

    attr_reader :pairs

    def method_missing(meth, *a, &block)
      STDERR << "MM(#{meth.inspect}, #{a.inspect}, #{block}, [#{@visitor.inspect}] #{caller[0..8]*"\n"}\n"
    end

  end

  class MyProcessor
    include ElementProcessor
  end

end

ARGV.each do |a|
  STDERR << "opening #{a.inspect}\n"
  if io = open(a)
    parser = XMLScan::XMLParser.new (visitor=MyVisitor::MyProcessor.new)
    parser.parse io
    STDERR << "Result\n"
    STDERR << visitor.pairs.map do |p|
        "#{p[0]}#{p[3]&&"[#{p[3]}]"}=>#{p[1]*''}"
      end * "\n"
    STDERR << "\nDone\n"
  else
    STDERR << "Error opening: #{$!}\n"
  end
end
