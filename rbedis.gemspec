$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
name = "rbedis"

Gem::Specification.new name, '0.0.1' do |s|
	s.summary = "Redis server in Ruby"
	s.authors = ["Pablo Merino"]
	s.email = "pablo@wearemocha.com"
	s.homepage = "http://github.com/pablo-merino/#{name}"
	s.files = `git ls-files`.split("\n")
	s.license = "MIT"
	s.add_dependency('active_support', ['~> 3.0.0'])
	s.add_dependency("colored", ["~> 1.2"])  
  s.add_dependency("eventmachine", ["~> 1.0.3"])
end
