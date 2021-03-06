# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "xmlscan"
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["UENO Katsuhiro <katsu@blue.sky.or.jp>"]
  s.date = "2012-02-26"
  s.description = "The fastest XML parser written in 100% pure Ruby."
  s.email = "gerryg@inbox.com"
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "ChangeLog",
    "Gemfile",
    "Gemfile.lock",
    "README.rdoc",
    "Rakefile",
    "THANKS",
    "VERSION",
    "lib/xmlscan/htmlscan.rb",
    "lib/xmlscan/namespace.rb",
    "lib/xmlscan/parser.rb",
    "lib/xmlscan/processor.rb",
    "lib/xmlscan/scanner.rb",
    "lib/xmlscan/version.rb",
    "lib/xmlscan/visitor.rb",
    "lib/xmlscan/xmlchar.rb"
  ]
  s.homepage = "http://github.com/GerryG/xmlformat/"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--main", "README.rdoc", "--inline-source", "--line-numbers"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.15"
  s.summary = "The fastest XML parser written in 100% pure Ruby."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.3"])
    else
      s.add_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 2.8.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
  end
end

