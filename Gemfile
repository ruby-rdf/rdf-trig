source "http://rubygems.org"

gemspec :name => ""

gem 'rdf',        :git => "git://github.com/ruby-rdf/rdf.git", :branch => "develop"
gem 'rdf-spec',   :git => "git://github.com/ruby-rdf/rdf-spec.git", :branch => "develop"
gem 'rdf-turtle', :git => "git://github.com/ruby-rdf/rdf-turtle.git", :branch => "develop"
gem 'ebnf',           :git => "git://github.com/gkellogg/ebnf.git", :branch => "develop"

group :debug do
  gem "wirble"
  gem "debugger", :platforms => :mri_19
  gem "byebug", :platforms => :mri_20
  gem "redcarpet", :platforms => :ruby
end

platforms :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'rubinius', '~> 2.0'
end
