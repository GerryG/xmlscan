# encoding: UTF-8

require 'xmlscan/parser'
require 'xmlscan/visitor'

module MyVisitor

  module ElementProcessor

    include XMLScan::Visitor

    def initialize()
      @pairs = []
      @context = ''
      @stack = []
      @out = []
      self
    end

    SKIP = %w{on_stag on_attribute on_attr_entityref on_attr_value
      on_attribute_end on_stag_end on_stag_empty_end on_etag}

    XMLScan::Visitor.instance_methods.each { |i|
      #unless instance_methods.member? i
      unless SKIP.member? i.to_s
        STDERR << "defining #{i}\n"
        #STDERR << "data #{i}:\#{args.inspect}\n"
        #@out << (args[1]||'#{i}')
        class_eval <<-END, __FILE__, __LINE__ + 1
          def #{i}(*args)
            @out << args[1]
          end
        END
      end
    }

    def on_stag_end(name, s, h, *a)
      if name.to_sym == :card
        STDERR << "sTag: #{a.inspect}\n" #{caller*"\n"}\n"
        @stack.push([s, @out])
        @context = h['name'] if h
        @out << [h['transclude'] || "{{#{@context}}}"]
      else @out << s end
    end
    def on_stag_empty_end(name, s=nil, h={}, *a)
      if name.to_sym == :card
         STDERR << "empty card ???: #{name}, #{s}, #{h.inspect}\n"
      else @out << s end
    end
    def on_etag(name, s=nil)
      if name.to_sym == :card
        @pairs << [@context, @out]
        STDERR << "eTag: #{name}, #{s}, #{@context}, #{@out}"
        @context, @out = @stack.pop
        STDERR << ", #{@context}, #{@out}\n"
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
    STDERR << visitor.pairs.map(&:to_s)*'' << "\n"
  else
    STDERR << "Error opening: #{$!}\n"
  end
end
