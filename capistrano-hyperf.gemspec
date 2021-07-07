# coding: utf-8
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-hyperf'
  spec.version       = '0.1.0'
  spec.authors       = ['Gang Wu']
  spec.email         = ['gokure@gmail.com']

  spec.summary       = 'Hyperf specific deployment options for Capistrano 3.x'
  spec.description   = 'Hyperf deployment for Capistrano 3.x'
  spec.homepage      = 'https://github.com/gokure/capistrano-hyperf'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'capistrano', '>= 3.0.0'
  spec.add_dependency 'capistrano-composer', '>= 0.0.6'
  spec.add_dependency 'capistrano-file-permissions', '>= 1.0.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
