require "rake"
require 'rake/contrib/rubyforgepublisher'
require 'rake/clean'
require 'rake/testtask'
require 'rdoc/task'

desc "Runs the Rspec suite"
task(:default) do
    run_suite
end

desc "Runs the Rspec suite"
task(:spec) do
    run_suite
end

def run_suite
    dir = File.dirname(__FILE__)
      system("ruby #{dir}/spec/spec_suite.rb") || raise("Spec Suite failed")
end

begin
    require 'jeweler'
    Jeweler::Tasks.new do |s|
      s.name = "xmlscan"
      s.version = '0.2.3'
      s.summary = "The fastest XML parser written in 100% pure Ruby."
      s.email = "gerryg@inbox.com"
      s.homepage = "http://github.com/GerryG/xmlformat/"
      s.description = "The fastest XML parser written in 100% pure Ruby."
      s.authors = ["UENO Katsuhiro <katsu@blue.sky.or.jp>"]
      s.files = FileList[
        '[A-Z]*',
        '*.rb',
        'lib/**/*.rb',
        'spec/**/*.rb' ].to_a
      s.test_files = Dir.glob('spec/*_spec.rb')
      s.has_rdoc = true
      s.extra_rdoc_files = [ "README.rdoc", "CHANGES" ]
      s.rdoc_options = ["--main", "README.rdoc", "--inline-source", "--line-numbers"]
                                                                                                                                                                end
rescue LoadError
    puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

=begin
class Jeweler
  module Commands
    class ReleaseToRubyforge
      def run
        raise NoRubyForgeProjectInGemspecError unless @gemspec.rubyforge_project
        @rubyforge.configure rescue nil

        output.puts 'Logging in rubyforge'
        @rubyforge.login

        @rubyforge.userconfig['release_notes'] = @gemspec.description if @gemspec.description
        @rubyforge.userconfig['preformatted'] = true

        output.puts "Releasing #{@gemspec.name}-#{@version} to #{@gemspec.rubyforge_project}"
        begin
          @rubyforge.add_release(@gemspec.rubyforge_project, RUBYFORGE_PACKAGE_NAME, @version.to_s, @gemspec_helper.gem_path)
        rescue StandardError => e
          case e.message
            when /no <group_id> configured for <#{Regexp.escape @gemspec.rubyforge_project}>/
              raise RubyForgeProjectNotConfiguredError, @gemspec.rubyforge_project
            when /no <package_id> configured for <#{Regexp.escape @gemspec.name}>/i
              raise MissingRubyForgePackageError, @gemspec.name
            else
              raise
          end
        end
      end
    end
  end
=end
