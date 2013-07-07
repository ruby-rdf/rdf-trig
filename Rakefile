#!/usr/bin/env ruby
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))
require 'rubygems'

namespace :gem do
  desc "Build the rdf-trig-#{File.read('VERSION').chomp}.gem file"
  task :build => "lib/rdf/trig/meta.rb" do
    sh "gem build rdf-trig.gemspec && mv rdf-trig-#{File.read('VERSION').chomp}.gem pkg/"
  end

  desc "Release the rdf-trig-#{File.read('VERSION').chomp}.gem file"
  task :release do
    sh "gem push pkg/rdf-trig-#{File.read('VERSION').chomp}.gem"
  end
end

desc 'Default: run specs.'
task :default => :spec
task :specs => :spec

require 'rspec/core/rake_task'
desc 'Run specifications'
RSpec::Core::RakeTask.new do |spec|
  spec.rspec_opts = %w(--options spec/spec.opts) if File.exists?('spec/spec.opts')
end

desc "Run specs through RCov"
RSpec::Core::RakeTask.new("spec:rcov") do |spec|
  spec.rcov = true
  spec.rcov_opts =  %q[--exclude "spec"]
end

desc "Generate HTML report specs"
RSpec::Core::RakeTask.new("doc:spec") do |spec|
  spec.rspec_opts = ["--format", "html", "-o", "doc/spec.html"]
end

require 'yard'
namespace :doc do
  YARD::Rake::YardocTask.new
end

desc 'Build first, follow and branch tables'
task :meta => "lib/rdf/trig/meta.rb"

file "lib/rdf/trig/meta.rb" => "etc/trig.bnf" do |t|
  sh %{
    ebnf --ll1 trigDoc --format rb \
      --mod-name RDF::TriG::Meta \
      --output lib/rdf/trig/meta.rb \
      etc/trig.bnf
  }
end

desc 'Create versions of ebnf files in etc'
task :etc => %w{etc/trig.sxp etc/trig.ll1.sxp}

file "etc/trig.ll1.sxp" => "etc/trig.bnf" do |t|
  sh %{
    ebnf --ll1 trigDoc --format sxp \
      --output etc/trig.ll1.sxp \
      etc/trig.bnf
  }
end

file "etc/trig.sxp" => "etc/trig.bnf" do |t|
  sh %{
    ebnf --bnf --format sxp \
      --output etc/trig.sxp \
      etc/trig.bnf
  }
end
