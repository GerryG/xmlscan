# encoding: UTF-8

require File.expand_path('../test_helper', File.dirname(__FILE__))
#
# tests/namespace.rb
#
#   Copyright (C) UENO Katsuhiro 2002
#
# $Id: testnamespace.rb,v 1.9.2.1 2003/02/28 12:35:17 katsu Exp $
#

require 'test/unit'
require 'xmlscan/namespace'
require File.expand_path('../helpers/visitor_helper', File.dirname(__FILE__))


class TestXMLNamespace < Test::Unit::TestCase

  include DefTestCase

  class Visitor < RecordingVisitor.new_class(XMLScan::NSVisitor)

    def on_stag_end_ns(qname, ns, *a)
      #STDERR << "on_stag_end_ns #{qname}, #{ns.inspect}, #{a.inspect}\n"
      super qname, ns.dup, *a
    end

    def on_stag_end_empty_ns(qname, ns, *a)
      #STDERR << "on_stag_end_empty_ns #{qname}, #{ns.inspect}, #{a.inspect}, #{caller*"\n"}\n"
      super qname, ns.dup, *a
    end

  end


  protected

  def setup
    @v = Visitor.new
    @s = XMLScan::XMLParserNS.new(@v)
  end

  def parse(src)
    @s.parse src
    @v.result
  end



  NS_XML   = 'http://www.w3.org/XML/1998/namespace'
  NS_XMLNS = 'http://www.w3.org/2000/xmlns/'


  public

  deftestcase 'default', <<-'TESTCASEEND'

  '<hoge xmlns="fuga"></hoge>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_stag_end_ns, 'hoge', {''=>'fuga'}, "<hoge xmlns=\"fuga\">", {"xmlns"=>"fuga"} ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<hoge xmlns="fuga"/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_stag_end_empty_ns, 'hoge', {""=>"fuga"}, "<hoge xmlns=\"fuga\"/>", {"xmlns"=>"fuga"} ]

  '<hoge></hoge>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_stag_end_ns, 'hoge', {}, "<hoge>", {} ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<hoge/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_stag_end_empty_ns, 'hoge', {}, "<hoge/>", {} ]
  

  '<hoge xmlns="fuga" foo="bar"/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_attribute_ns, 'foo', nil, 'foo' ]
  [ :on_attr_value, 'bar' ]
  [ :on_attribute_end, 'foo' ]
  [ :on_stag_end_empty_ns, 'hoge', {''=>'fuga'}, '<hoge xmlns="fuga" foo="bar"/>', {'xmlns'=>'fuga', 'foo'=>'bar'} ]

  '<hoge foo="bar" xmlns="fuga"/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_attribute_ns, 'foo', nil, 'foo' ]
  [ :on_attr_value, 'bar' ]
  [ :on_attribute_end, 'foo' ]
  [ :on_stag_end_empty_ns, 'hoge', {''=>'fuga'}, "<hoge foo=\"bar\" xmlns=\"fuga\"/>", {"foo"=>"bar", "xmlns"=>"fuga"} ]

  '<hoge xmlns="fu&#103;a"/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_stag_end_empty_ns, 'hoge', {''=>'fuga'}, "<hoge xmlns=\"fu&#103;a\"/>", {"xmlns"=>"fu&#103;a"} ]

  '<hoge xmlns="fu&#x67;a"/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_stag_end_empty_ns, 'hoge', {''=>'fuga'}, "<hoge xmlns=\"fu&#x67;a\"/>", {"xmlns"=>"fu&#x67;a"} ]

  '<hoge xmlns="fu&foo;a"/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :ns_wellformed_error, "xmlns includes undeclared entity reference" ]
  [ :on_stag_end_empty_ns, 'hoge', {''=>'fua'}, "<hoge xmlns=\"fu&foo;a\"/>", {"xmlns"=>"fu&foo;a"} ]

  '<hoge xmlns="foo"><fuga/></hoge>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_stag_end_ns, 'hoge', {''=>'foo'}, "<hoge xmlns=\"foo\">", {"xmlns"=>"foo"} ]
  [ :on_stag_ns, 'fuga', '', 'fuga' ]
  [ :on_stag_end_empty_ns, 'fuga', {''=>'foo'}, "<fuga/>", {} ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<hoge xmlns="foo"><fuga xmlns="bar"/><moga/></hoge>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_stag_end_ns, 'hoge', {''=>'foo'}, "<hoge xmlns=\"foo\">", {"xmlns"=>"foo"} ]
  [ :on_stag_ns, 'fuga', '', 'fuga' ]
  [ :on_stag_end_empty_ns, 'fuga', {''=>'bar'}, "<fuga xmlns=\"bar\"/>", {"xmlns"=>"bar"} ]
  [ :on_stag_ns, 'moga', '', 'moga' ]
  [ :on_stag_end_empty_ns, 'moga', {''=>'foo'}, "<moga/>", {} ]
  [ :on_etag, 'hoge', "</hoge>" ]

  '<hoge xmlns="foo"><fuga xmlns=""><moga/></fuga></hoge>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_stag_end_ns, 'hoge', {''=>'foo'}, '<hoge xmlns="foo">', {'xmlns'=>'foo'} ]
  [ :on_stag_ns, 'fuga', '', 'fuga' ]
  [ :on_stag_end_ns, 'fuga', {''=>nil}, '<fuga xmlns="">', {'xmlns'=>''} ]
  [ :on_stag_ns, 'moga', '', 'moga' ]
  [ :on_stag_end_empty_ns, 'moga', {''=>nil}, '<moga/>', {} ]
  [ :on_etag, 'fuga', '</fuga>' ]
  [ :on_etag, 'hoge', '</hoge>' ]

  TESTCASEEND



  deftestcase 'prefix', <<-'TESTCASEEND'

  '<foo:hoge xmlns:foo="fuga"></foo:hoge>'
  [ :on_stag_ns, 'foo:hoge', 'foo', 'hoge' ]
  [ :on_stag_end_ns, 'foo:hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'fuga'}, "<foo:hoge xmlns:foo=\"fuga\">", {"xmlns:foo"=>"fuga"} ]
  [ :on_etag, 'foo:hoge', "</foo:hoge>" ]

  '<foo:hoge xmlns:foo="fuga"/>'
  [ :on_stag_ns, 'foo:hoge', 'foo', 'hoge' ]
  [ :on_stag_end_empty_ns, 'foo:hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'fuga'}, "<foo:hoge xmlns:foo=\"fuga\"/>", {"xmlns:foo"=>"fuga"} ]

  '<foo:hoge></foo:hoge>'
  [ :on_stag_ns, 'foo:hoge', 'foo', 'hoge' ]
  [ :ns_wellformed_error, "prefix `foo' is not declared" ]
  [ :on_stag_end_ns, 'foo:hoge', {}, '<foo:hoge>', {} ]
  [ :on_etag, 'foo:hoge', '</foo:hoge>' ]

  '<foo:hoge/>'
  [ :on_stag_ns, 'foo:hoge', 'foo', 'hoge' ]
  [ :ns_wellformed_error, "prefix `foo' is not declared" ]
  [ :on_stag_end_empty_ns, 'foo:hoge', {}, '<foo:hoge/>', {} ]

  '<foo:hoge:fuga/>'
  [ :ns_parse_error, "localpart `hoge:fuga' includes `:'" ]
  [ :on_stag_ns, 'foo:hoge:fuga', 'foo', 'hoge:fuga' ]
  [ :ns_wellformed_error, "prefix `foo' is not declared" ]
  [ :on_stag_end_empty_ns, 'foo:hoge:fuga', {}, '<foo:hoge:fuga/>', {} ]

  '<foo:hoge xmlns:foo="fuga" foo="bar"/>'
  [ :on_stag_ns, 'foo:hoge', 'foo', 'hoge' ]
  [ :on_attribute_ns, 'foo', nil, 'foo' ]
  [ :on_attr_value, 'bar' ]
  [ :on_attribute_end, 'foo' ]
  [ :on_stag_end_empty_ns, 'foo:hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'fuga'}, '<foo:hoge xmlns:foo="fuga" foo="bar"/>', {'xmlns:foo'=>'fuga', 'foo'=>'bar'} ]

  '<foo:hoge foo="bar" xmlns:foo="fuga"/>'
  [ :on_stag_ns, 'foo:hoge', 'foo', 'hoge' ]
  [ :on_attribute_ns, 'foo', nil, 'foo' ]
  [ :on_attr_value, 'bar' ]
  [ :on_attribute_end, 'foo' ]
  [ :on_stag_end_empty_ns, 'foo:hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'fuga'},  '<foo:hoge foo="bar" xmlns:foo="fuga"/>', {'foo'=>'bar', 'xmlns:foo'=>'fuga'} ]

  '<bar:hoge xmlns:foo="fuga"/>'
  [ :on_stag_ns, 'bar:hoge', 'bar', 'hoge' ]
  [ :ns_wellformed_error, "prefix `bar' is not declared" ]
  [ :on_stag_end_empty_ns, 'bar:hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'fuga'}, '<bar:hoge xmlns:foo="fuga"/>', {'xmlns:foo'=>"fuga"} ]

  '<foo:hoge xmlns:foo=""/>'
  [ :on_stag_ns, 'foo:hoge', 'foo', 'hoge' ]
  [ :ns_parse_error, "`foo' is bound to empty namespace name" ]
  [ :on_stag_end_empty_ns, 'foo:hoge', {'xmlns'=>NS_XMLNS, 'foo'=>''}, '<foo:hoge xmlns:foo=""/>', {'xmlns:foo'=>''} ]

  '<foo:hoge xmlns:foo="fu&#103;a"/>'
  [ :on_stag_ns, 'foo:hoge', 'foo', 'hoge' ]
  [ :on_stag_end_empty_ns, 'foo:hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'fuga'}, '<foo:hoge xmlns:foo="fu&#103;a"/>', {'xmlns:foo'=>'fu&#103;a'} ]

  '<foo:hoge xmlns:foo="fu&#x67;a"/>'
  [ :on_stag_ns, 'foo:hoge', 'foo', 'hoge' ]
  [ :on_stag_end_empty_ns, 'foo:hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'fuga'}, "<foo:hoge xmlns:foo=\"fu&#x67;a\"/>", {"xmlns:foo"=>"fu&#x67;a"} ]

  '<foo:hoge xmlns:foo="fu&foo;a"/>'
  [ :on_stag_ns, 'foo:hoge', 'foo', 'hoge' ]
  [ :ns_wellformed_error, "xmlns includes undeclared entity reference" ]
  [ :on_stag_end_empty_ns, 'foo:hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'fua'}, "<foo:hoge xmlns:foo=\"fu&foo;a\"/>", {"xmlns:foo"=>"fu&foo;a"} ]

  '<foo:hoge xmlns:foo="foo"><foo:fuga/></foo:hoge>'
  [ :on_stag_ns, 'foo:hoge', 'foo', 'hoge' ]
  [ :on_stag_end_ns, 'foo:hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'foo'}, "<foo:hoge xmlns:foo=\"foo\">", {"xmlns:foo"=>"foo"} ]
  [ :on_stag_ns, 'foo:fuga', 'foo', 'fuga' ]
  [ :on_stag_end_empty_ns, 'foo:fuga', {'xmlns'=>NS_XMLNS, 'foo'=>'foo'}, "<foo:fuga/>", {} ]
  [ :on_etag, 'foo:hoge', '</foo:hoge>' ]

  '<foo:hoge xmlns:foo="foo"><foo:fuga xmlns:foo="bar"/><foo:moga/></foo:hoge>'
  [ :on_stag_ns, 'foo:hoge', 'foo', 'hoge' ]
  [ :on_stag_end_ns, 'foo:hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'foo'}, "<foo:hoge xmlns:foo=\"foo\">", {"xmlns:foo"=>"foo"} ]
  [ :on_stag_ns, 'foo:fuga', 'foo', 'fuga' ]
  [ :on_stag_end_empty_ns, 'foo:fuga', {'xmlns'=>NS_XMLNS, 'foo'=>'bar'}, "<foo:fuga xmlns:foo=\"bar\"/>", {"xmlns:foo"=>"bar"} ]
  [ :on_stag_ns, 'foo:moga', 'foo', 'moga' ]
  [ :on_stag_end_empty_ns, 'foo:moga', {'xmlns'=>NS_XMLNS, 'foo'=>'foo'}, "<foo:moga/>", {} ]
  [ :on_etag, 'foo:hoge', '</foo:hoge>' ]

  '<foo:hoge xmlns:foo="foo"><foo:fuga xmlns:foo="bar"><foo:moga/></foo:fuga></foo:hoge>'
  [ :on_stag_ns, 'foo:hoge', 'foo', 'hoge' ]
  [ :on_stag_end_ns, 'foo:hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'foo'}, '<foo:hoge xmlns:foo="foo">', {'xmlns:foo'=>'foo'} ]
  [ :on_stag_ns, 'foo:fuga', 'foo', 'fuga' ]
  [ :on_stag_end_ns, 'foo:fuga', {'xmlns'=>NS_XMLNS, 'foo'=>'bar'}, '<foo:fuga xmlns:foo="bar">', {'xmlns:foo'=>"bar"} ]
  [ :on_stag_ns, 'foo:moga', 'foo', 'moga' ]
  [ :on_stag_end_empty_ns, 'foo:moga', {'xmlns'=>NS_XMLNS, 'foo'=>'bar'}, '<foo:moga/>', {} ]
  [ :on_etag, 'foo:fuga', '</foo:fuga>' ]
  [ :on_etag, 'foo:hoge', '</foo:hoge>' ]

  '<foo:hoge xmlns:foo="foo" xmlns:bar="bar"/>'
  [ :on_stag_ns, 'foo:hoge', 'foo', 'hoge' ]
  [ :on_stag_end_empty_ns, 'foo:hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'foo', 'bar'=>'bar'}, '<foo:hoge xmlns:foo="foo" xmlns:bar="bar"/>', {'xmlns:foo'=>'foo', 'xmlns:bar'=>'bar'} ]

  '<foo:hoge xmlns:foo="foo" xmlns:bar="bar"><bar:fuga/></foo:hoge>'
  [ :on_stag_ns, 'foo:hoge', 'foo', 'hoge' ]
  [ :on_stag_end_ns, 'foo:hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'foo', 'bar'=>'bar'}, "<foo:hoge xmlns:foo=\"foo\" xmlns:bar=\"bar\">", {"xmlns:foo"=>"foo", "xmlns:bar"=>"bar"} ]
  [ :on_stag_ns, 'bar:fuga', 'bar', 'fuga' ]
  [ :on_stag_end_empty_ns, 'bar:fuga', {'xmlns'=>NS_XMLNS, 'foo'=>'foo', 'bar'=>'bar'}, '<bar:fuga/>', {} ]
  [ :on_etag, 'foo:hoge', '</foo:hoge>' ]

  '<foo:hoge xmlns:foo="foo" xmlns:bar="bar"><bar:fuga xmlns:foo="baz"/><moga/></foo:hoge>'
  [ :on_stag_ns, 'foo:hoge', 'foo', 'hoge' ]
  [ :on_stag_end_ns, 'foo:hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'foo', 'bar'=>'bar'}, "<foo:hoge xmlns:foo=\"foo\" xmlns:bar=\"bar\">", {"xmlns:foo"=>"foo", "xmlns:bar"=>"bar"} ]
  [ :on_stag_ns, 'bar:fuga', 'bar', 'fuga' ]
  [ :on_stag_end_empty_ns, 'bar:fuga', {'xmlns'=>NS_XMLNS, 'foo'=>'baz', 'bar'=>'bar'}, "<bar:fuga xmlns:foo=\"baz\"/>", {"xmlns:foo"=>"baz"} ]
  [ :on_stag_ns, 'moga', '', 'moga' ]
  [ :on_stag_end_empty_ns, 'moga', {'xmlns'=>NS_XMLNS, 'foo'=>'foo', 'bar'=>'bar'}, "<moga/>", {} ]
  [ :on_etag, 'foo:hoge', '</foo:hoge>' ]

  '<hoge><foo:hoge xmlns:foo="foo" xmlns:bar="bar"/><fuga/></hoge>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_stag_end_ns, 'hoge', {}, '<hoge>', {} ]
  [ :on_stag_ns, 'foo:hoge', 'foo', 'hoge' ]
  [ :on_stag_end_empty_ns, 'foo:hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'foo', 'bar'=>'bar'}, '<foo:hoge xmlns:foo="foo" xmlns:bar="bar"/>', {'xmlns:foo'=>'foo', 'xmlns:bar'=>'bar'} ]
  [ :on_stag_ns, 'fuga', '', 'fuga' ]
  [ :on_stag_end_empty_ns, 'fuga', {'xmlns'=>NS_XMLNS, 'foo'=>nil, 'bar'=>nil}, '<fuga/>', {} ]
  [ :on_etag, 'hoge', '</hoge>' ]

  TESTCASEEND



  deftestcase 'attribute', <<-'TESTCASEEND'

  '<hoge xmlns="bar" fuga="moga"/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_attribute_ns, 'fuga', nil, 'fuga' ]
  [ :on_attr_value, 'moga' ]
  [ :on_attribute_end, 'fuga' ]
  [ :on_stag_end_empty_ns, 'hoge', {''=>'bar'}, '<hoge xmlns="bar" fuga="moga"/>', {"xmlns"=>"bar", "fuga"=>"moga", 'xmlns'=>'bar'} ]

  '<hoge xmlns:foo="bar" foo:fuga="moga"/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_attribute_ns, 'foo:fuga', 'foo', 'fuga' ]
  [ :on_attr_value, 'moga' ]
  [ :on_attribute_end, 'foo:fuga' ]
  [ :on_stag_end_empty_ns, 'hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'bar'}, '<hoge xmlns:foo="bar" foo:fuga="moga"/>', {"xmlns:foo"=>"bar", 'foo:fuga'=>'moga'} ]

  '<hoge xmlns:foo="bar" bar:fuga="moga"/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_attribute_ns, 'bar:fuga', 'bar', 'fuga' ]
  [ :on_attr_value, 'moga' ]
  [ :on_attribute_end, 'bar:fuga' ]
  [ :ns_wellformed_error, "prefix `bar' is not declared" ]
  [ :on_stag_end_empty_ns, 'hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'bar'}, '<hoge xmlns:foo="bar" bar:fuga="moga"/>', {'xmlns:foo'=>'bar', 'bar:fuga'=>'moga'} ]

  '<hoge xmlns:foo="bar"><fuga foo:baz="moga"/></hoge>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_stag_end_ns, 'hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'bar'}, '<hoge xmlns:foo="bar">', {"xmlns:foo"=>"bar"} ]
  [ :on_stag_ns, 'fuga', '', 'fuga' ]
  [ :on_attribute_ns, 'foo:baz', 'foo', 'baz' ]
  [ :on_attr_value, 'moga' ]
  [ :on_attribute_end, 'foo:baz' ]
  [ :on_stag_end_empty_ns, 'fuga', {'xmlns'=>NS_XMLNS, 'foo'=>'bar'}, '<fuga foo:baz="moga"/>', {'foo:baz'=>'moga'} ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<hoge xmlns:foo="bar" xmlns:bar="baz" foo:fuga="moga" bar:fuga="gema"/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_attribute_ns, 'foo:fuga', 'foo', 'fuga' ]
  [ :on_attr_value, 'moga' ]
  [ :on_attribute_end, 'foo:fuga' ]
  [ :on_attribute_ns, 'bar:fuga', 'bar', 'fuga' ]
  [ :on_attr_value, 'gema' ]
  [ :on_attribute_end, 'bar:fuga' ]
  [ :on_stag_end_empty_ns, 'hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'bar', 'bar'=>'baz'}, '<hoge xmlns:foo="bar" xmlns:bar="baz" foo:fuga="moga" bar:fuga="gema"/>', {'xmlns:foo'=>'bar', 'xmlns:bar'=>'baz', 'foo:fuga'=>'moga', 'bar:fuga'=>'gema'} ]

  '<hoge xmlns:foo="bar" xmlns:bar="bar" foo:fuga="moga" bar:fuga="gema"/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_attribute_ns, 'foo:fuga', 'foo', 'fuga' ]
  [ :on_attr_value, 'moga' ]
  [ :on_attribute_end, 'foo:fuga' ]
  [ :on_attribute_ns, 'bar:fuga', 'bar', 'fuga' ]
  [ :on_attr_value, 'gema' ]
  [ :on_attribute_end, 'bar:fuga' ]
  [ :ns_wellformed_error, "doubled localpart `fuga' in the same namespace" ]
  [ :on_stag_end_empty_ns, 'hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'bar', 'bar'=>'bar'}, '<hoge xmlns:foo="bar" xmlns:bar="bar" foo:fuga="moga" bar:fuga="gema"/>', {"xmlns:foo"=>"bar", "xmlns:bar"=>"bar", "foo:fuga"=>"moga", "bar:fuga"=>"gema"} ]

  '<hoge foo:fuga="moga" bar:fuga="gema" xmlns:foo="bar" xmlns:bar="bar"/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_attribute_ns, 'foo:fuga', 'foo', 'fuga' ]
  [ :on_attr_value, 'moga' ]
  [ :on_attribute_end, 'foo:fuga' ]
  [ :on_attribute_ns, 'bar:fuga', 'bar', 'fuga' ]
  [ :on_attr_value, 'gema' ]
  [ :on_attribute_end, 'bar:fuga' ]
  [ :ns_wellformed_error, "doubled localpart `fuga' in the same namespace" ]
  [ :on_stag_end_empty_ns, 'hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'bar', 'bar'=>'bar'}, '<hoge foo:fuga="moga" bar:fuga="gema" xmlns:foo="bar" xmlns:bar="bar"/>', {'foo:fuga'=>'moga', 'bar:fuga'=>'gema', "xmlns:foo"=>"bar", "xmlns:bar"=>"bar"} ]

  '<hoge xmlns:foo="moga"><fuga foo:bar="a" baz:bar="a" xmlns:baz="moga"/></hoge>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_stag_end_ns, 'hoge', {'xmlns'=>NS_XMLNS, 'foo'=>'moga'}, '<hoge xmlns:foo="moga">', {"xmlns:foo"=>"moga"} ]
  [ :on_stag_ns, 'fuga', '', 'fuga' ]
  [ :on_attribute_ns, 'foo:bar', 'foo', 'bar' ]
  [ :on_attr_value, 'a' ]
  [ :on_attribute_end, 'foo:bar' ]
  [ :on_attribute_ns, 'baz:bar', 'baz', 'bar' ]
  [ :on_attr_value, 'a' ]
  [ :on_attribute_end, 'baz:bar' ]
  [ :ns_wellformed_error, "doubled localpart `bar' in the same namespace" ]
  [ :on_stag_end_empty_ns, 'fuga', {'xmlns'=>NS_XMLNS, 'foo'=>'moga', 'baz'=>'moga'}, '<fuga foo:bar="a" baz:bar="a" xmlns:baz="moga"/>', {'foo:bar'=>'a', 'baz:bar'=>'a', "xmlns:baz"=>"moga"} ]
  [ :on_etag, 'hoge', '</hoge>' ]

  '<foo foo:bar:fuga="hoge" xmlns:foo="bar" xmlns:bar="bar"/>'
  [ :on_stag_ns, 'foo', '', 'foo' ]
  [ :ns_parse_error, "localpart `bar:fuga' includes `:'" ]
  [ :on_attribute_ns, 'foo:bar:fuga', 'foo', 'bar:fuga' ]
  [ :on_attr_value, 'hoge' ]
  [ :on_attribute_end, 'foo:bar:fuga' ]
  [ :on_stag_end_empty_ns, 'foo', {'xmlns'=>NS_XMLNS, 'foo'=>'bar', 'bar'=>'bar'}, '<foo foo:bar:fuga="hoge" xmlns:foo="bar" xmlns:bar="bar"/>', {'foo:bar:fuga'=>'hoge', "xmlns:foo"=>"bar", "xmlns:bar"=>"bar"} ]

  TESTCASEEND



  deftestcase 'reserved', <<-'TESTCASEEND'

  '<hoge xml:lang="ja"/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_attribute_ns, 'xml:lang', 'xml', 'lang' ]
  [ :on_attr_value, 'ja' ]
  [ :on_attribute_end, 'xml:lang' ]
  [ :on_stag_end_empty_ns, 'hoge', {'xml'=>NS_XML}, '<hoge xml:lang="ja"/>', {'xml:lang'=>'ja'} ]

  '<foo><bar><baz xml:lang="ja"/></bar><hoge/></foo>'
  [ :on_stag_ns, 'foo', '', 'foo' ]
  [ :on_stag_end_ns, 'foo', {}, '<foo>', {} ]
  [ :on_stag_ns, 'bar', '', 'bar' ]
  [ :on_stag_end_ns, 'bar', {}, '<bar>', {} ]
  [ :on_stag_ns, 'baz', '', 'baz' ]
  [ :on_attribute_ns, 'xml:lang', 'xml', 'lang' ]
  [ :on_attr_value, 'ja' ]
  [ :on_attribute_end, 'xml:lang' ]
  [ :on_stag_end_empty_ns, 'baz', {'xml'=>NS_XML}, '<baz xml:lang="ja"/>', {'xml:lang'=>'ja'} ]
  [ :on_etag, 'bar', '</bar>' ]
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_stag_end_empty_ns, 'hoge', {'xml'=>NS_XML}, '<hoge/>', {} ]
  [ :on_etag, 'foo', '</foo>' ]

  '<xmlns:hoge/>'
  [ :ns_wellformed_error, "prefix `xmlns' is not used for namespace prefix declaration" ]
  [ :on_stag_ns, 'xmlns:hoge', 'xmlns', 'hoge' ]
  [ :on_stag_end_empty_ns, 'xmlns:hoge', {'xmlns'=>NS_XMLNS}, '<xmlns:hoge/>', {} ]

  '<hoge xmlns:xml="fuga"/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :ns_wellformed_error, "prefix `xml' can't be bound to any namespace except `http://www.w3.org/XML/1998/namespace'" ]
  [ :on_stag_end_empty_ns, 'hoge', {'xmlns'=>NS_XMLNS, 'xml'=>'fuga'}, '<hoge xmlns:xml="fuga"/>', {"xmlns:xml"=>"fuga"} ]

  '<hoge xmlns:xml="http://www.w3.org/XML/1998/namespace"/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_stag_end_empty_ns, 'hoge', {'xmlns'=>NS_XMLNS, 'xml'=>NS_XML}, '<hoge xmlns:xml="http://www.w3.org/XML/1998/namespace"/>', {'xmlns:xml'=>'http://www.w3.org/XML/1998/namespace'} ]

  '<hoge xmlns:fuga="http://www.w3.org/XML/1998/namespace"/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :ns_wellformed_error, "namespace `http://www.w3.org/XML/1998/namespace' is reserved for prefix `xml'" ]
  [ :on_stag_end_empty_ns, 'hoge', {'xmlns'=>NS_XMLNS, 'fuga'=>NS_XML}, '<hoge xmlns:fuga="http://www.w3.org/XML/1998/namespace"/>', {'xmlns:fuga'=>'http://www.w3.org/XML/1998/namespace'} ]

  '<hoge xmlns:xmlns="fuga"/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :ns_wellformed_error, "prefix `xmlns' can't be bound to any namespace explicitly" ]
  [ :on_stag_end_empty_ns, 'hoge', {'xmlns'=>'fuga'}, '<hoge xmlns:xmlns="fuga"/>', {'xmlns:xmlns'=>'fuga'} ]

  '<hoge xmlns:xmlns="http://www.w3.org/2000/xmlns/"/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :ns_wellformed_error, "prefix `xmlns' can't be bound to any namespace explicitly" ]
  [ :on_stag_end_empty_ns, 'hoge', {'xmlns'=>NS_XMLNS}, '<hoge xmlns:xmlns="http://www.w3.org/2000/xmlns/"/>', {'xmlns:xmlns'=>"http://www.w3.org/2000/xmlns/"} ]

  '<hoge xmlns:fuga="http://www.w3.org/2000/xmlns/"/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :ns_wellformed_error, "namespace `http://www.w3.org/2000/xmlns/' is reserved for prefix `xmlns'" ]
  [ :on_stag_end_empty_ns, 'hoge', {'xmlns'=>NS_XMLNS, 'fuga'=>NS_XMLNS}, '<hoge xmlns:fuga="http://www.w3.org/2000/xmlns/"/>', {'xmlns:fuga'=>"http://www.w3.org/2000/xmlns/"} ]

  TESTCASEEND



  deftestcase 'wellformedness', <<-'TESTCASEEND'

  '<!DOCTYPE foo:bar><hoge/>'
  [ :on_doctype, 'foo:bar', nil, nil ]
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_stag_end_empty_ns, 'hoge', {}, '<hoge/>', {} ]

  '<!DOCTYPE foo:bar:baz><hoge/>'
  [ :ns_parse_error, "qualified name `foo:bar:baz' includes `:'" ]
  [ :on_doctype, 'foo:bar:baz', nil, nil ]
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_stag_end_empty_ns, 'hoge', {}, '<hoge/>', {} ]

  '<?foo?><hoge/>'
  [ :on_pi, 'foo', '' ]
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_stag_end_empty_ns, 'hoge', {}, '<hoge/>', {} ]

  '<?foo:bar?><hoge/>'
  [ :ns_parse_error, "PI target `foo:bar' includes `:'" ]
  [ :on_pi, 'foo:bar', '' ]
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_stag_end_empty_ns, 'hoge', {}, '<hoge/>', {} ]

  '<hoge fuga="&foo:bar;"/>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_attribute_ns, 'fuga', nil, 'fuga' ]
  [ :ns_parse_error, "entity reference `foo:bar' includes `:'" ]
  [ :on_attr_entityref, 'foo:bar', '&foo:bar;' ]
  [ :on_attribute_end, 'fuga' ]
  [ :on_stag_end_empty_ns, 'hoge', {}, '<hoge fuga="&foo:bar;"/>', {'fuga'=>"&foo:bar;"} ]

  '<hoge>&foo:bar;</hoge>'
  [ :on_stag_ns, 'hoge', '', 'hoge' ]
  [ :on_stag_end_ns, 'hoge', {}, '<hoge>', {} ]
  [ :ns_parse_error, "entity reference `foo:bar' includes `:'" ]
  [ :on_entityref, 'foo:bar', '&foo:bar;' ]
  [ :on_etag, 'hoge', '</hoge>' ]

  TESTCASEEND





end

