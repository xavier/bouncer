Gem::Specification.new do |s|
  s.name    = 'bouncer'
  s.version = '0.0.1'
  s.date    = '2009-08-07'
  
  s.summary = "Rack middleware for simple access filtering by IP address or User Agent"
  s.description = "Rack middleware for simple access filtering by IP address or User Agent"
  
  s.authors  = ['Xavier Defrang']
  s.email    = 'xavier.defrang@gmail.com'
  s.homepage = 'http://github.com/xavier/bouncer'
  
  s.has_rdoc = true
  s.rdoc_options = ['--main', 'README.rdoc']
  s.rdoc_options << '--inline-source' << '--charset=UTF-8'
  s.extra_rdoc_files = ['README.rdoc']
  
  s.files = %w(Rakefile README.rdoc lib/bouncer.rb test/bouncer_test.rb)
  s.test_files = %w(test/bouncer_test.rb)
end