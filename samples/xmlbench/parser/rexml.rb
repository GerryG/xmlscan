#
# samples/xmlbench/parser/rexml.rb
#
#   Copyright (C) UENO Katsuhiro 2002
#
# $Id: rexml.rb,v 1.1 2002/12/26 17:32:46 katsu Exp $
#

require 'rexml/document'
require 'rexml/streamlistener'


class BenchREXMLStream < XMLBench

  class REXMLListener
    include REXML::StreamListener
  end

  def name
    'REXML::Document.parse_stream'
  end

  def parse(src)
    s = REXML::SourceFactory.create_from(src)
    REXML::Document.parse_stream s, REXMLListener.new
  end

end


class BenchREXMLTree < XMLBench

  class REXMLListener
    include REXML::StreamListener
  end

  def name
    'REXML::Document.new'
  end

  def parse(src)
    REXML::Document.new src
  end

end
