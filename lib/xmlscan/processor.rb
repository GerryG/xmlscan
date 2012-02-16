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
      (mod ? MY_METHODS - mod.instance_methods : MY_METHODS).each do |i|
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

    def self.process(file, opts={}, mod=nil)
      raise "Not readable #{file.inspect}" unless IO===( io =
                                             IO===file ? file : open(file) )
      visitor = new(opts, mod)
      visitor.parser.parse(io)
      visitor.pairs
    end
  end

end
