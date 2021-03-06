# encoding: UTF-8

require File.expand_path('../test_helper', File.dirname(__FILE__))
#
# tests/testparser.rb
#
#   Copyright (C) UENO Katsuhiro 2002
#
# $Id: testparser.rb,v 1.15.2.1 2003/02/28 12:35:17 katsu Exp $
#

require 'test/unit'
require File.expand_path('../helpers/visitor_helper', File.dirname(__FILE__))
require 'xmlscan/parser'


class TestXMLParser < Test::Unit::TestCase

  include DefTestCase

  Visitor = RecordingVisitor.new_class(XMLScan::Visitor)


  protected

  def setup
    @v = Visitor.new
    @s = XMLScan::XMLParser.new(@v)
  end

  def parse(src)
    @s.parse src
    @v.result
  end


  public

  deftestcase 'xmldecl', <<-'TESTCASEEND'

  '<?xml version="1.0" ?><hoge/>'
  [ :on_xmldecl ]
  [ :on_xmldecl_version, '1.0' ]
  [ :on_xmldecl_end ]
  [ :on_stag, 'hoge' ]
  [ :on_stag_end_empty, 'hoge', '<hoge/>', {} ]

  '<?xml version="1.01" ?><hoge/>'
  [ :on_xmldecl ]
  [ :warning, "unsupported XML version `1.01'" ]
  [ :on_xmldecl_version, '1.01' ]
  [ :on_xmldecl_end ]
  [ :on_stag, 'hoge' ]
  [ :on_stag_end_empty, 'hoge', '<hoge/>', {} ]

  '<?xml version="1.0" standalone="yes" ?><hoge/>'
  [ :on_xmldecl ]
  [ :on_xmldecl_version, '1.0' ]
  [ :on_xmldecl_standalone, 'yes' ]
  [ :on_xmldecl_end ]
  [ :on_stag, 'hoge' ]
  [ :on_stag_end_empty, 'hoge', '<hoge/>', {} ]

  '<?xml version="1.0" standalone="no" ?><hoge/>'
  [ :on_xmldecl ]
  [ :on_xmldecl_version, '1.0' ]
  [ :on_xmldecl_standalone, 'no' ]
  [ :on_xmldecl_end ]
  [ :on_stag, 'hoge' ]
  [ :on_stag_end_empty, 'hoge', '<hoge/>', {} ]

  '<?xml version="1.0" standalone="hoge" ?><hoge/>'
  [ :on_xmldecl ]
  [ :on_xmldecl_version, '1.0' ]
  [ :parse_error, "standalone declaration must be either `yes' or `no'" ]
  [ :on_xmldecl_standalone, 'hoge' ]
  [ :on_xmldecl_end ]
  [ :on_stag, 'hoge' ]
  [ :on_stag_end_empty, 'hoge', '<hoge/>', {} ]

  '<?xml version="1.0" standalone="YES" ?><hoge/>'
  [ :on_xmldecl ]
  [ :on_xmldecl_version, '1.0' ]
  [ :parse_error, "standalone declaration must be either `yes' or `no'" ]
  [ :on_xmldecl_standalone, 'YES' ]
  [ :on_xmldecl_end ]
  [ :on_stag, 'hoge' ]
  [ :on_stag_end_empty, 'hoge', '<hoge/>', {} ]

  TESTCASEEND



  deftestcase 'doctype', <<-'TESTCASEEND'

  '<!DOCTYPE hoge PUBLIC "foo" "bar"><hoge/>'
  [ :on_doctype, 'hoge', 'foo', 'bar' ]
  [ :on_stag, 'hoge' ]
  [ :on_stag_end_empty, 'hoge', '<hoge/>', {} ]

  '<!DOCTYPE hoge PUBLIC "foo"><hoge/>'
  [ :parse_error, "public external ID must have both public ID and system ID" ]
  [ :on_doctype, 'hoge', 'foo', nil ]
  [ :on_stag, 'hoge' ]
  [ :on_stag_end_empty, 'hoge', '<hoge/>', {} ]

  '<!DOCTYPE hoge SYSTEM "foo"><hoge/>'
  [ :on_doctype, 'hoge', nil, 'foo' ]
  [ :on_stag, 'hoge' ]
  [ :on_stag_end_empty, 'hoge', '<hoge/>', {} ]

  TESTCASEEND



  deftestcase 'ignore_space', <<-'TESTCASEEND'

  '<?xml version="1.0"?>  <!DOCTYPE hoge>  <hoge/>'
  [ :on_xmldecl ]
  [ :on_xmldecl_version, '1.0' ]
  [ :on_xmldecl_end ]
  [ :on_doctype, 'hoge', nil, nil ]
  [ :on_stag, 'hoge' ]
  [ :on_stag_end_empty, 'hoge', '<hoge/>', {} ]

  '<?xml version="1.0"?>  <!DOCTYPE hoge>  <hoge/>  '
  [ :on_xmldecl ]
  [ :on_xmldecl_version, '1.0' ]
  [ :on_xmldecl_end ]
  [ :on_doctype, 'hoge', nil, nil ]
  [ :on_stag, 'hoge' ]
  [ :on_stag_end_empty, 'hoge', '<hoge/>', {} ]

  '  <!DOCTYPE hoge>  <hoge>  </hoge>  '
  [ :on_doctype, 'hoge', nil, nil ]
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_chardata, '  ' ]
  [ :on_etag, 'hoge', '</hoge>' ]

  TESTCASEEND



  deftestcase 'pi', <<-'TESTCASEEND'

  ' <?xml ?><hoge/>'
  [ :parse_error, "reserved PI target `xml'" ]
  [ :on_pi, 'xml', '' ]
  [ :on_stag, 'hoge' ]
  [ :on_stag_end_empty, 'hoge', '<hoge/>', {} ]

  ' <?Xml ?><hoge/>'
  [ :parse_error, "reserved PI target `Xml'" ]
  [ :on_pi, 'Xml', '' ]
  [ :on_stag, 'hoge' ]
  [ :on_stag_end_empty, 'hoge', '<hoge/>', {} ]

  ' <?XML ?><hoge/>'
  [ :parse_error, "reserved PI target `XML'" ]
  [ :on_pi, 'XML', '' ]
  [ :on_stag, 'hoge' ]
  [ :on_stag_end_empty, 'hoge', '<hoge/>', {} ]

  TESTCASEEND




  deftestcase 'element_nesting', <<-'TESTCASEEND'

  '<hoge></hoge>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<hoge><fuga></fuga></hoge>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_stag, 'fuga' ]
  [ :on_stag_end, 'fuga', '<fuga>', {} ]
  [ :on_etag, 'fuga', '</fuga>' ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<hoge><fuga/></hoge>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_stag, 'fuga' ]
  [ :on_stag_end_empty, 'fuga', '<fuga/>', {} ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<hoge/>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end_empty, 'hoge', '<hoge/>', {} ]

  '<hoge><fuga>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_stag, 'fuga' ]
  [ :on_stag_end, 'fuga', '<fuga>', {} ]
  [ :parse_error, "unclosed element `fuga' meets EOF" ]
  [ :on_etag, 'fuga' ]
  [ :parse_error, "unclosed element `hoge' meets EOF" ]
  [ :on_etag, 'hoge' ]

  '<hoge><fuga></fuga>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_stag, 'fuga' ]
  [ :on_stag_end, 'fuga', '<fuga>', {} ]
  [ :on_etag, 'fuga', '</fuga>' ]
  [ :parse_error, "unclosed element `hoge' meets EOF" ]
  [ :on_etag, 'hoge' ]

  '<hoge><fuga></hoge></fuga>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_stag, 'fuga' ]
  [ :on_stag_end, 'fuga', '<fuga>', {} ]
  [ :wellformed_error, "element type `hoge' is not matched" ]
  [ :on_etag, 'fuga', '</hoge>' ]
  [ :wellformed_error, "element type `fuga' is not matched" ]
  [ :on_etag, 'hoge', '</fuga>' ]

  '<hoge></fuga>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :wellformed_error, "element type `fuga' is not matched" ]
  [ :on_etag, 'hoge', '</fuga>' ]

  '</hoge>'
  [ :parse_error, "end tag `hoge' appears alone" ]
  [ :parse_error, "no root element was found" ]

  '<hoge></hoge><fuga>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_etag, 'hoge', '</hoge>' ]
  [ :parse_error, "another root element is found" ]
  [ :on_stag, 'fuga' ]
  [ :on_stag_end, 'fuga', '<fuga>', {} ]
  [ :parse_error, "unclosed element `fuga' meets EOF" ]
  [ :on_etag, 'fuga' ]

  '<hoge></hoge></fuga>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_etag, 'hoge', '</hoge>' ]
  [ :parse_error, "end tag `fuga' appears alone" ]

  '<hoge/><fuga/>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end_empty, 'hoge', '<hoge/>', {} ]
  [ :parse_error, "another root element is found" ]
  [ :on_stag, 'fuga' ]
  [ :on_stag_end_empty, 'fuga', '<fuga/>', {} ]

  TESTCASEEND



  deftestcase 'outside', <<-'TESTCASEEND'

  '<hoge>fuga</hoge>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_chardata, 'fuga' ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '  <hoge>fuga</hoge>  '
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_chardata, 'fuga' ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<hoge><![CDATA[fuga]]></hoge>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_cdata, 'fuga' ]
  [ :on_etag, 'hoge', '</hoge>' ]

  'fuga<hoge></hoge>'
  [ :parse_error, "content of element is found outside of root element" ]
  [ :on_chardata, 'fuga' ]
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<![CDATA[fuga]]><hoge></hoge>'
  [ :parse_error, "CDATA section is found outside of root element" ]
  [ :on_cdata, 'fuga' ]
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<hoge></hoge>fuga'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_etag, 'hoge', '</hoge>' ]
  [ :parse_error, "content of element is found outside of root element" ]
  [ :on_chardata, 'fuga' ]

  '<hoge></hoge><![CDATA[fuga]]>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_etag, 'hoge', '</hoge>' ]
  [ :parse_error, "CDATA section is found outside of root element" ]
  [ :on_cdata, 'fuga' ]

  '<hoge></hoge><fuga>foo</fuga>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_etag, 'hoge', '</hoge>' ]
  [ :parse_error, "another root element is found" ]
  [ :on_stag, 'fuga' ]
  [ :on_stag_end, 'fuga', '<fuga>', {} ]
  [ :on_chardata, 'foo' ]
  [ :on_etag, 'fuga', '</fuga>' ]

  '<hoge></hoge><fuga><![CDATA[fuga]]></fuga>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_etag, 'hoge', '</hoge>' ]
  [ :parse_error, "another root element is found" ]
  [ :on_stag, 'fuga' ]
  [ :on_stag_end, 'fuga', '<fuga>', {} ]
  [ :on_cdata, 'fuga' ]
  [ :on_etag, 'fuga', '</fuga>' ]

  TESTCASEEND



  deftestcase 'entityref', <<-'TESTCASEEND'

  '<hoge>foo&lt;bar</hoge>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_chardata, 'foo' ]
  [ :on_entityref, 'lt', '&lt;' ]
  [ :on_chardata, 'bar' ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<hoge>foo&gt;bar</hoge>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_chardata, 'foo' ]
  [ :on_entityref, 'gt', '&gt;' ]
  [ :on_chardata, 'bar' ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<hoge>foo&amp;bar</hoge>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_chardata, 'foo' ]
  [ :on_entityref, 'amp', '&amp;' ]
  [ :on_chardata, 'bar' ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<hoge>foo&quot;bar</hoge>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_chardata, 'foo' ]
  [ :on_entityref, 'quot', '&quot;' ]
  [ :on_chardata, 'bar' ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<hoge>foo&apos;bar</hoge>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_chardata, 'foo' ]
  [ :on_entityref, 'apos', '&apos;' ]
  [ :on_chardata, 'bar' ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<hoge>foo&fuga;bar</hoge>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_chardata, 'foo' ]
  [ :on_entityref, 'fuga', '&fuga;' ]
  [ :on_chardata, 'bar' ]
  [ :on_etag, 'hoge', '</hoge>' ]

  TESTCASEEND



  deftestcase 'charref', <<-'TESTCASEEND'

  '<hoge>fu&#103;a</hoge>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_chardata, 'fu' ]
  [ :on_charref, 103, '&#103;' ]
  [ :on_chardata, 'a' ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<hoge>fu&#x67;a</hoge>'
  [ :on_stag, 'hoge' ]
  [ :on_stag_end, 'hoge', '<hoge>', {} ]
  [ :on_chardata, 'fu' ]
  [ :on_charref_hex, 103, '&#x67;' ]
  [ :on_chardata, 'a' ]
  [ :on_etag, 'hoge', '</hoge>' ]

  TESTCASEEND



  deftestcase 'attr_entityref', <<-'TESTCASEEND'

  '<hoge fuga="foo&lt;bar"></hoge>'
  [ :on_stag, 'hoge' ]
  [ :on_attribute, 'fuga' ]
  [ :on_attr_value, 'foo' ]
  [ :on_attr_entityref, 'lt', '&lt;' ]
  [ :on_attr_value, 'bar' ]
  [ :on_attribute_end, 'fuga' ]
  [ :on_stag_end, 'hoge', "<hoge fuga=\"foo&lt;bar\">", {"fuga"=>"foo&lt;bar"} ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<hoge fuga="foo&gt;bar"></hoge>'
  [ :on_stag, 'hoge' ]
  [ :on_attribute, 'fuga' ]
  [ :on_attr_value, 'foo' ]
  [ :on_attr_entityref, 'gt', '&gt;' ]
  [ :on_attr_value, 'bar' ]
  [ :on_attribute_end, 'fuga' ]
  [ :on_stag_end, 'hoge', "<hoge fuga=\"foo&gt;bar\">", {"fuga"=>"foo&gt;bar"} ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<hoge fuga="foo&amp;bar"></hoge>'
  [ :on_stag, 'hoge' ]
  [ :on_attribute, 'fuga' ]
  [ :on_attr_value, 'foo' ]
  [ :on_attr_entityref, 'amp', '&amp;' ]
  [ :on_attr_value, 'bar' ]
  [ :on_attribute_end, 'fuga' ]
  [ :on_stag_end, 'hoge', "<hoge fuga=\"foo&amp;bar\">", {"fuga"=>"foo&amp;bar"} ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<hoge fuga="foo&quot;bar"></hoge>'
  [ :on_stag, 'hoge' ]
  [ :on_attribute, 'fuga' ]
  [ :on_attr_value, 'foo' ]
  [ :on_attr_entityref, 'quot', '&quot;'  ]
  [ :on_attr_value, 'bar' ]
  [ :on_attribute_end, 'fuga' ]
  [ :on_stag_end, 'hoge', "<hoge fuga=\"foo&quot;bar\">", {"fuga"=>"foo&quot;bar"} ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<hoge fuga="foo&apos;bar"></hoge>'
  [ :on_stag, 'hoge' ]
  [ :on_attribute, 'fuga' ]
  [ :on_attr_value, 'foo' ]
  [ :on_attr_entityref, 'apos', '&apos;' ]
  [ :on_attr_value, 'bar' ]
  [ :on_attribute_end, 'fuga' ]
  [ :on_stag_end, 'hoge', "<hoge fuga=\"foo&apos;bar\">", {"fuga"=>"foo&apos;bar"} ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<hoge fuga="foo&HOGE;bar"></hoge>'
  [ :on_stag, 'hoge' ]
  [ :on_attribute, 'fuga' ]
  [ :on_attr_value, 'foo' ]
  [ :on_attr_entityref, 'HOGE', '&HOGE;' ]
  [ :on_attr_value, 'bar' ]
  [ :on_attribute_end, 'fuga' ]
  [ :on_stag_end, 'hoge', "<hoge fuga=\"foo&HOGE;bar\">", {"fuga"=>"foo&HOGE;bar"} ]
  [ :on_etag, 'hoge', '</hoge>' ]

  TESTCASEEND



  deftestcase 'attr_charref', <<-'TESTCASEEND'

  '<hoge foo="fu&#103;a"/>'
  [ :on_stag, 'hoge' ]
  [ :on_attribute, 'foo' ]
  [ :on_attr_value, 'fu' ]
  [ :on_attr_charref, 103, '&#103;' ]
  [ :on_attr_value, 'a' ]
  [ :on_attribute_end, 'foo' ]
  [ :on_stag_end_empty, 'hoge', '<hoge foo="fu&#103;a"/>', {'foo'=>"fu&#103;a"} ]

  '<hoge foo="fu&#x67;a"/>'
  [ :on_stag, 'hoge' ]
  [ :on_attribute, 'foo' ]
  [ :on_attr_value, 'fu' ]
  [ :on_attr_charref_hex, 103, '&#x67;' ]
  [ :on_attr_value, 'a' ]
  [ :on_attribute_end, 'foo' ]
  [ :on_stag_end_empty, 'hoge', '<hoge foo="fu&#x67;a"/>', {'foo'=>"fu&#x67;a"} ]

  TESTCASEEND



  deftestcase 'normalize', <<-'TESTCASEEND'

  "<hoge fuga=' foo bar '></hoge>"
  [ :on_stag, 'hoge' ]
  [ :on_attribute, 'fuga' ]
  [ :on_attr_value, ' foo bar ' ]
  [ :on_attribute_end, 'fuga' ]
  [ :on_stag_end, 'hoge', "<hoge fuga=' foo bar '>", {'fuga'=>' foo bar '} ]
  [ :on_etag, 'hoge', '</hoge>' ]

  "<hoge fuga='\tfoo\nbar\t'></hoge>"
  [ :on_stag, 'hoge' ]
  [ :on_attribute, 'fuga' ]
  [ :on_attr_value, ' foo bar ' ]
  [ :on_attribute_end, 'fuga' ]
  [ :on_stag_end, 'hoge', "<hoge fuga='\tfoo\nbar\t'>", {'fuga'=>' foo bar '} ]
  [ :on_etag, 'hoge', "</hoge>" ]

  "<hoge fuga='\tfoo\r\nbar\t'></hoge>"
  [ :on_stag, 'hoge' ]
  [ :on_attribute, 'fuga' ]
  [ :on_attr_value, ' foo  bar ' ]
  [ :on_attribute_end, 'fuga' ]
  [ :on_stag_end, 'hoge', "<hoge fuga='\tfoo\r\nbar\t'>", { 'fuga'=>' foo  bar '} ]
  [ :on_etag, 'hoge', "</hoge>" ]

  "<hoge fuga='\tfoo\r\nbar\t'></hoge>"
  [ :on_stag, 'hoge' ]
  [ :on_attribute, 'fuga' ]
  [ :on_attr_value, ' foo  bar ' ]
  [ :on_attribute_end, 'fuga' ]
  [ :on_stag_end, 'hoge', "<hoge fuga='\tfoo\r\nbar\t'>", {'fuga'=>' foo  bar '} ]
  [ :on_etag, 'hoge', "</hoge>"  ]

  "<hoge fuga='\tfoo&#9;bar\t'></hoge>"
  [ :on_stag, 'hoge' ]
  [ :on_attribute, 'fuga' ]
  [ :on_attr_value, ' foo' ]
  [ :on_attr_charref, 9, '&#9;' ]
  [ :on_attr_value, 'bar ' ]
  [ :on_attribute_end, 'fuga' ]
  [ :on_stag_end, 'hoge', "<hoge fuga='\tfoo&#9;bar\t'>", {'fuga'=>"\tfoo&#9;bar\t"} ]
  [ :on_etag, 'hoge', "</hoge>"  ]

  TESTCASEEND



  deftestcase 'attribute', <<-'TESTCASEEND'

  '<hoge foo="bar" bar="fuga"/>'
  [ :on_stag, 'hoge' ]
  [ :on_attribute, 'foo' ]
  [ :on_attr_value, 'bar' ]
  [ :on_attribute_end, 'foo' ]
  [ :on_attribute, 'bar' ]
  [ :on_attr_value, 'fuga' ]
  [ :on_attribute_end, 'bar' ]
  [ :on_stag_end_empty, 'hoge', '<hoge foo="bar" bar="fuga"/>', {'foo'=>'bar', 'bar'=>'fuga'} ]

  '<hoge foo="bar" foo="fuga"/>'
  [ :on_stag, 'hoge' ]
  [ :on_attribute, 'foo' ]
  [ :on_attr_value, 'bar' ]
  [ :on_attribute_end, 'foo' ]
  [ :wellformed_error, "doubled attribute `foo'" ]
  [ :on_attribute, 'foo' ]
  [ :on_attr_value, 'fuga' ]
  [ :on_attribute_end, 'foo' ]
  [ :on_stag_end_empty, 'hoge', "<hoge foo=\"bar\" foo=\"fuga\"/>", {"foo"=>"fuga"} ]

  '<hoge foo="bar" foo="fuga" foo="hoge"/>'
  [ :on_stag, 'hoge' ]
  [ :on_attribute, 'foo' ]
  [ :on_attr_value, 'bar' ]
  [ :on_attribute_end, 'foo' ]
  [ :wellformed_error, "doubled attribute `foo'" ]
  [ :on_attribute, 'foo' ]
  [ :on_attr_value, 'fuga' ]
  [ :on_attribute_end, 'foo' ]
  [ :wellformed_error, "doubled attribute `foo'" ]
  [ :on_attribute, 'foo' ]
  [ :on_attr_value, 'hoge' ]
  [ :on_attribute_end, 'foo' ]
  [ :on_stag_end_empty, 'hoge', "<hoge foo=\"bar\" foo=\"fuga\" foo=\"hoge\"/>", {"foo"=>"hoge"} ]

  TESTCASEEND

end


