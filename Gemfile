source "http://rubygems.org"

gemspec

gem 'rdf',        git: "git://github.com/ruby-rdf/rdf.git", branch: "develop"
gem 'ebnf',           git: "git://github.com/gkellogg/ebnf.git", branch: "develop"

group :development do
  gem "wirble"
  gem "byebug", platforms: :mri_21
  gem 'psych',      platforms: [:mri, :rbx]
end

group :development, :test do
  gem "redcarpet", :platforms => :ruby
  gem 'rdf-spec',   git: "git://github.com/ruby-rdf/rdf-spec.git", branch: "develop"
  gem 'rdf-turtle', git: "git://github.com/ruby-rdf/rdf-turtle.git", branch: "develop"
  gem 'simplecov',  require: false
  gem 'coveralls',  require: false
end

platforms :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'rubinius', '~> 2.0'
  gem 'json'
end
