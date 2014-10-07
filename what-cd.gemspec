
$:.push File.expand_path("../lib", __FILE__)
require "what-cd/version"

Gem::Specification.new do |s|
  s.name        = "what-cd"
  s.version     = WhatCD::VERSION
  s.summary     = "Useful CLI tools for What.cd"
  s.description = "Useful CLI tools for What.cd"
  s.authors     = ["Jason Parraga"]
  s.email       = ["sovietaced@gmail.com"]
  s.homepage    = "https://github.com/Sovietaced/what-cd"
  s.files       = Dir['README.md', 'lib/**/*', 'bin/**/*']
  s.executables = ['what-cd']

  s.add_dependency "flac2mp3"
  s.add_dependency "mktorrent"
end