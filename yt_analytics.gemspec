# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require File.dirname(__FILE__) + "/lib/yt_analytics/version"

Gem::Specification.new do |s|
  s.name        = "yt_analytics"
  s.version     = YTAnalytics::VERSION
  s.authors     = %w(drewbaumann sstavrop)
  s.email       = %w(drewbaumann@gmail.com)
  s.description = "Upload, delete, update, comment on youtube videos all from one gem."
  s.summary     = "The most complete Ruby wrapper for youtube api's"
  s.homepage    = "http://github.com/fullscreeninc/yt_analytics"

  s.add_runtime_dependency("nokogiri", "~> 1.5.2")
  s.add_runtime_dependency("oauth", "~> 0.4.4")
  s.add_runtime_dependency("oauth2", "~> 0.6")
  s.add_runtime_dependency("simple_oauth", "~> 0.1.5")
  s.add_runtime_dependency("faraday", "~> 0.8")
  s.add_runtime_dependency("builder", ">= 0")

  s.files = Dir.glob("lib/**/*") + %w(README.rdoc yt_analytics.gemspec)

  s.extra_rdoc_files = %w(README.rdoc)
end

