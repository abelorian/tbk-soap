lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'tbk-soap'
  s.version     = '0.0.8'
  s.date        = '2017-08-09'
  s.summary     = "Ruby implementation of Transbank's Webpay SOAP protocol"
  s.description = "Ruby implementation of Transbank's Webpay SOAP protocol"
  s.authors     = ["Abel O'Rian"]
  s.email       = 'abel@welcu.com'
  s.homepage    = 'http://rubygems.org/gems/tbk-soap'
  s.license       = 'MIT'
  s.files         = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.require_paths = ["lib"]

  s.add_dependency 'savon', '~> 2.11.1'
  s.add_dependency 'signer'

end
