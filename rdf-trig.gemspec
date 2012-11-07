#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version               = File.read('VERSION').chomp
  gem.date                  = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name                  = "rdf-trig"
  gem.homepage              = "http://github.com/ruby-rdf/rdf-trig"
  gem.license               = 'Public Domain' if gem.respond_to?(:license=)
  gem.summary               = "TriG reader/writer for Ruby."
  gem.description           = %q{RDF::TriG is an TriG reader/writer for the RDF.rb library suite.}
  gem.rubyforge_project     = 'rdf-trig'

  gem.authors               = ['Gregg Kellogg']
  gem.email                 = 'public-rdf-ruby@w3.org'

  gem.platform              = Gem::Platform::RUBY
  gem.files                 = %w(AUTHORS README.markdown History UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  #gem.bindir               = %q(bin)
  #gem.default_executable   = gem.executables.first
  gem.require_paths         = %w(lib)
  gem.extensions            = %w()
  gem.test_files            = %w()
  gem.has_rdoc              = false

  gem.required_ruby_version = '>= 1.8.1'
  gem.requirements          = []
  gem.add_runtime_dependency     'rdf',             '>= 0.3.9'
  gem.add_runtime_dependency     'rdf-turtle',      '>= 0.3.0'
  gem.add_development_dependency 'open-uri-cached', '>= 0.0.4'
  gem.add_development_dependency 'json-ld',         '>= 0.3.0'
  gem.add_development_dependency 'rdf-n3',          '>= 0.3.7'
  gem.add_development_dependency 'rspec',           '>= 2.8.0'
  gem.add_development_dependency 'rdf-isomorphic',  '>= 0.3.4'
  gem.add_development_dependency 'yard' ,           '>= 0.6.0'
  gem.add_development_dependency 'sxp',             '>= 0.0.14'
  gem.add_development_dependency 'rdf-spec',        '>= 0.3.8'
  gem.add_development_dependency 'rspec',           '>= 2.11.0'
  gem.add_development_dependency 'rake'
  gem.post_install_message  = nil
end