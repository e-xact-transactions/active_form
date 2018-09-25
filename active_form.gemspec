Gem::Specification.new do |s|
  s.name        = 'exact-active_form'
  s.version     = '5.2.0'
  s.platform    = Gem::Platform::RUBY
  s.summary     = 'Validations for Non Active Record Models.'
  s.description = 'Rails >= 5 is required.'

  s.required_ruby_version     = '>= 2.4'
  
  s.authors  = ['Torsten Braun', 'Donncha Redmond']
  s.email    = 'dredmond@e-xact.com'
  s.homepage = 'http://github.com/exact/active_form'

  s.require_paths = ["lib"]

  s.files = [
    "README.md",
    "LICENCE",
    "Rakefile",
    "Gemfile",
    "lib/active_form.rb",
    "active_form.gemspec",
    "test/test_helper.rb",
    "test/basic_test.rb"
  ]

  s.test_files = [
    "test/test_helper.rb",
    "test/basic_test.rb"
  ]

  s.add_dependency('activemodel', '>= 5')
end
