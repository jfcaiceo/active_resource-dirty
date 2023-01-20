$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require 'active_resource/dirty/version'

Gem::Specification.new do |spec|
  spec.name        = 'active_resource-dirty'
  spec.version     = ActiveResource::Dirty::VERSION
  spec.authors     = ['Francisco Caiceo']
  spec.email       = ['jfcaiceo55@gmail.com']
  spec.homepage    = 'https://github.com/jfcaiceo/active_resource-dirty'
  spec.summary     = 'ActiveModel::Dirty support for ActiveResource'
  spec.description = 'Monkey Patch to support ActiveModel::Dirty methods in ActiveResource'
  spec.license     = 'MIT'

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency 'activemodel', '>= 5.2.0', '< 7'
  spec.add_dependency 'activeresource', '~> 5.1.0'
  spec.add_dependency 'activesupport', '>= 5.2.0', '< 8'
end
