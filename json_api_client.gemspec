$:.push File.expand_path("../lib", __FILE__)

# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.

require 'json_api_client/version'

Gem::Specification.new do |s|
  s.name = "json_api_client"
  s.version = JsonApiClient::VERSION
  s.description = 'Build client libraries compliant with specification defined by jsonapi.org'
  s.summary = 'Build client libraries compliant with specification defined by jsonapi.org'

  s.add_dependency "activesupport", '>= 3.2.0'
  s.add_dependency "faraday", '>= 0.15.2', '< 1.2.0'
  s.add_dependency "faraday_middleware", '>= 0.9.0', '< 1.2.0'
  s.add_dependency "addressable", '~> 2.2'
  s.add_dependency "activemodel", '>= 3.2.0'
  s.add_dependency "rack", '>= 0.2'

  s.add_development_dependency "webmock", '~> 3.5.1'
  s.add_development_dependency "mocha"

  s.license = "MIT"

  s.author = "Jeff Ching"
  s.email = "ching.jeff@gmail.com"
  s.homepage = "http://github.com/chingor13/json_api_client"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir.glob('test/*_test.rb')
end
