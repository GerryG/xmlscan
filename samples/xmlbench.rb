#!/usr/bin/ruby
#
# samples/xmlbench.rb
#
#   Copyright (C) UENO Katsuhiro 2002
#
# $Id: xmlbench.rb,v 1.5 2002/12/26 17:32:46 katsu Exp $
#

require 'samples/xmlbench/xmlbench-lib'
require 'benchmark'

$KCODE = 'U'


source = ARGV.shift

unless source then
  STDERR.print "#$0: no source document is given.\n"
  exit 1
end

if ARGV.empty? then
  subjects = XMLBench.setup_all
else
  subjects = XMLBench.setup(*ARGV)
end



def t(test, arg)
  repeat = 1
  a = []       # ensure that there are at least 100,000 recycled objects
  99999.times { a.push Object.new }
  a = nil
  GC.start
  #GC.disable
  begin
    test.report(arg,'') { repeat.times { yield } }
  rescue Exception => e
    puts "  #{e.class.name}"
  ensure
    #GC.enable
  end
end



Benchmark.bm(30) { |test|
  File.open(source) { |f|
    puts '** File **'
    subjects.each { |i|
      f.rewind
      t(test, i.name) { i.parse f }
    }

    puts '** Array **'
    f.rewind
    src = f.readlines
    subjects.each { |i|
      t(test, i.name) { i.parse src }
    }

    puts '** String **'
    f.rewind
    src = f.read
    subjects.each { |i|
      src2 = src.dup        # xmlscan-20011123 breaks source string.
      t(test, i.name) { i.parse src2 }
    }
  }
}
