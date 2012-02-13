# encoding: UTF-8

require File.expand_path('../test_helper', File.dirname(__FILE__))
#
# tests/xmlchar.rb
#
#   Copyright (C) Ueno Katsuhiro 2002
#
# $Id: testxmlchar.rb,v 1.1.4.1 2003/02/28 12:35:17 katsu Exp $
#

require 'test/unit'
require 'xmlscan/xmlchar'
require File.expand_path('../helpers/visitor_helper', File.dirname(__FILE__))


class TestXMLChar < Test::Unit::TestCase

  include XMLScan::XMLChar

  def test_valid_char_p1
    assert_equal true, valid_char?(9)
  end
  def test_valid_char_p2
    assert_equal true, valid_char?(10)
  end
  def test_valid_char_p3
    assert_equal true, valid_char?(13)
  end
  def test_valid_char_p4
    assert_equal true, valid_char?(32)
  end
  def test_valid_char_p5
    assert_equal false, valid_char?(8)
  end
  def test_valid_char_p6
    assert_equal true, valid_char?(0xfffd)
  end
  def test_valid_char_p7
    assert_equal false, valid_char?(0xfffe)
  end
  def test_valid_char_p8
    assert_equal false, valid_char?(0xffff)
  end
  def test_valid_char_p9
    assert_equal false, valid_char?(0x200000)
  end


  # \xE3\x81\xBB = ho
  # \xE3\x81\x92 = ge
  # \xE3\x81\xB5 = fu
  # \xE3\x81\x8C = ga

  Hoge = "\xE3\x81\xBB\xE3\x81\x92"
  Fuga = "\xE3\x81\xB5\xE3\x81\x8C"

  Testcases = [
    #                   chardata? nmtoken?    name?
    [ 'hogefuga',           true,    true,    true ], # 1
    [ Hoge+Fuga,            true,    true,    true ], # 2
    [ Hoge+' '+Fuga,        true,   false,   false ], # 3
    [ Hoge+"\n"+Fuga,       true,   false,   false ], # 4
    [ Hoge+"\r"+Fuga,       true,   false,   false ], # 5
    [ Hoge+"\t"+Fuga,       true,   false,   false ], # 6
    [ Hoge+"\f"+Fuga,      false,   false,   false ], # 7
    [ Hoge+'.'+Fuga,        true,    true,    true ], # 8
    [ Hoge+'-'+Fuga,        true,    true,    true ], # 9
    [ Hoge+'_'+Fuga,        true,    true,    true ], # 10
    [ Hoge+':'+Fuga,        true,    true,    true ], # 11
    [ Hoge+'%'+Fuga,        true,   false,   false ], # 12
    [ '.'+Hoge+Fuga,        true,    true,   false ], # 13
    [ '-'+Hoge+Fuga,        true,    true,   false ], # 14
    [ '_'+Hoge+Fuga,        true,    true,    true ], # 15
    [ ':'+Hoge+Fuga,        true,    true,    true ], # 16
    [ '%'+Hoge+Fuga,        true,   false,   false ], # 17
    [ Hoge+"\xfe"+Fuga,    false,   false,   false ], # 18
    [ Hoge+"\xff"+Fuga,    false,   false,   false ], # 19
    [ [0xffff].pack('U'),  false,   false,   false ], # 20
  ]


  def test_valid_chardata_p
    n=0
    errs=[]
    Testcases.each { |str,expect,|
      n=n+1
      errs << "#{n}[#{expect}]#{str.inspect}" unless expect == (str.valid_encoding? && valid_chardata?(str))
    }
    assert errs == [], "Invalid chardata #{errs*"\n"}"
  end

  def test_valid_nmtoken_p
    n=0
    errs=[]
    Testcases.each { |str,dummy,expect,|
      n=n+1
      errs << "#{n}[#{expect}]#{str.inspect}" unless expect == (str.valid_encoding? && valid_nmtoken?(str))
    }
    assert errs == [], "Invalid token #{errs*"\n"}"
  end

  def test_valid_name_p
    n=0
    errs=[]
    Testcases.each { |str,dummy,dummy1,expect, *a|
      n=n+1
      errs << "#{n}[#{expect}]#{str.inspect}" unless expect == (str.valid_encoding? && valid_name?(str))
       
    }
    assert errs == [], "Invalid names #{errs*"\n"}"
  end

end



class TestXMLScannerStrict < Test::Unit::TestCase

  include DefTestCase

  Visitor = RecordingVisitor.new_class(XMLScan::Visitor)


  protected

  def setup
    #@origkcode = $KCODE
    #$KCODE = 'U'
    @v = Visitor.new
    @s = XMLScan::XMLScanner.new(@v, :strict_char)
  end

  def teardown
    #$KCODE = @origkcode
  end

  def parse(src)
    @s.parse src
    @v.result
  end


  public

  Hoge = TestXMLChar::Hoge
  Fuga = TestXMLChar::Fuga


  deftestcase 'document', <<-'TESTCASEEND'

  "<:.#{Hoge}>hoge</:.#{Hoge}>"
  [ :on_stag, ":.#{Hoge}" ]
  [ :on_stag_end, ":.#{Hoge}" ]
  [ :on_chardata, "hoge" ]
  [ :on_etag, ":.#{Hoge}" ]

  "<.:#{Hoge}>hoge</.:#{Hoge}>"
  [ :parse_error, "`.:#{Hoge}' is not valid for XML name"]
  [ :on_stag, ".:#{Hoge}" ]
  [ :on_stag_end, ".:#{Hoge}" ]
  [ :on_chardata, "hoge" ]
  [ :parse_error, "`.:#{Hoge}' is not valid for XML name"]
  [ :on_etag, ".:#{Hoge}" ]

  TESTCASEEND

end

