Gem::Specification.new do |s|
  s.name          = 'bloc-record'
  s.version       = '0.0.0'
  s.date          = '2017-12-08'
  s.summary       = 'BlocRecord ORM'
  s.description   = 'An ActiveRecord-esque ORM adapter'
  s.authors       = ['Scott Lenander']
  s.email         = 'sjlteacher@gmail.com'
  s.files         = Dir['lib/**/*.rb']
  s.require_paths = ["lib"]
  s.homepage      =
    'http://rubygems.org/gems/bloc_record'
  s.license       = 'MIT'
  s.add_runtime_dependency  'sqlite3', '~> 1.3'
  s.add_runtime_dependency  'activesupport'
  s.add_runtime_dependency  'pg', '~> 0.21.0'
end
