source "http://rubygems.org"

gemspec

gem 'rdf',        github: "ruby-rdf/rdf",         branch: "develop"
gem 'rdf-turtle', github: "ruby-rdf/rdf-turtle",  branch: "develop"
gem 'ebnf',       github: "gkellogg/ebnf",        branch: "develop"

group :development do
  gem "wirble"
  gem "byebug",   platforms: :mri
  gem 'psych',    platforms: [:mri, :rbx]
end

group :development, :test do
  gem 'json-ld',        github: "ruby-rdf/json-ld",         branch: "develop"
  gem 'rdf-spec',       github: "ruby-rdf/rdf-spec",        branch: "develop"
  gem 'rdf-isomorphic', github: "ruby-rdf/rdf-isomorphic",  branch: "develop"
  gem 'rdf-vocab',      github: "ruby-rdf/rdf-vocab",       branch: "develop"
  gem 'sxp',            github: "dryruby/sxp.rb",           branch: "develop"
  gem "redcarpet",      platform: :ruby
  gem 'simplecov',      require: false, platform: :mri
  gem 'coveralls',      require: false, platform: :mri
end

platforms :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'rubinius', '~> 2.0'
  gem 'json'
end
