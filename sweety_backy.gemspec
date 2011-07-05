# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sweety_backy"

Gem::Specification.new do |s|
  s.name        = "sweety_backy"
  s.version     = SweetyBacky::VERSION
  s.authors     = ["Fernando Guillen"]
  s.email       = ["fguillen.mail@gmail.com"]
  s.homepage    = "https://github.com/fguillen/SweetyBacky"
  s.summary     = "Ruby backup mechanism"
  s.description = "Simple mechanism to configure and execute backups of folders and MySQL DBs and store them in local folder or S3 bucket"

  s.rubyforge_project = "SweetyBacky"
  
  s.add_development_dependency "bundler", ">= 1.0.0.rc.6"
  s.add_development_dependency "mocha"
  s.add_development_dependency "delorean"
  
  s.add_dependency "s3"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
