#!/usr/bin/ruby
#
# runtest.rb
#
# $Id: runtest.rb,v 1.3.4.2 2003/05/01 15:43:23 katsu Exp $
#

require 'test/unit'
require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'

$SAFE = 2 rescue nil
STDOUT.sync = true
STDERR.sync = true


# if no testcases is specified especially, do nothing here and
# leave everything up to Test::Unit.
exit if ARGV.empty?


if ARGV[0] == '-v' then
  output_level = Test::Unit::UI::Console::TestRunner::VERBOSE
  ARGV.shift
else
  output_level = Test::Unit::UI::Console::TestRunner::NORMAL
end


argv = ARGV.collect { |i| i.split(/[#:]/, 2) }  # [ class, testcase ]

def argv.exactly_include?(classname)
  empty? or find{ |i| i == [classname] }
end
def argv.testcases(classname)
  select{ |i| i.first == classname }.collect{ |i| i.last }
end


suite = Test::Unit::TestSuite.new
ObjectSpace.each_object(Class) { |c|
  if /\ATest/ =~ c.name and not c.equal? Test::Unit::TestCase and
      c.ancestors.include? Test::Unit::TestCase then
    if argv.exactly_include? c.name then
      suite << c.suite
    else
      argv.testcases(c.name).each { |i| suite << c.new(i) }
    end
  end
}

Test::Unit::UI::Console::TestRunner.run suite, output_level
