Gem::Specification.new do |s|
  s.name        = "fancy_buff"
  s.version     = "3.0.0"
  s.description = "a text buffer with marks, selections, and simple insert/delete"
  s.summary     = "want to have a small line-based text buffer with named marks and selections, very rudimentary editing, but absolutely nothing else? then this library is for you."
  s.authors     = ["Jeff Lunt"]
  s.email       = "jefflunt@gmail.com"
  s.files       = ["lib/fancy_buff.rb"]
  s.homepage    = "https://github.com/jefflunt/fancy_buff"
  s.license     = "MIT"

  s.add_dependency 'rouge', '~> 4.1'

  s.add_development_dependency 'minitest'
end
