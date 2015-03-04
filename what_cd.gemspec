
$:.push File.expand_path("../lib", __FILE__)
require "what_cd/version"

Gem::Specification.new do |s|
  s.name        = "what_cd"
  s.version     = WhatCD::VERSION
  s.summary     = "Useful CLI tools for What.cd"
  s.description = "Useful CLI tools for What.cd"
  s.authors     = ["Jason Parraga"]
  s.email       = ["sovietaced@gmail.com"]
  s.homepage    = "https://github.com/Sovietaced/what-cd"
  s.files       = Dir['README.md', 'lib/**/*', 'bin/**/*']
  s.executables = ['what_cd']

  s.add_dependency "commander"
  s.add_dependency "mp3info"
  s.add_dependency "mktorrent"
end