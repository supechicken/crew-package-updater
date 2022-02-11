#!/usr/bin/env ruby
require 'fileutils'
require_relative 'wrapper'

repo = 'skycocker/chromebrew'
pkgName = ARGV[0]
pkgUrl = "https://raw.githubusercontent.com/#{repo}/master/packages/#{pkgName}.rb"

eval `curl -Ls '#{pkgUrl}' || echo "abort 'Download failed!'"`
pkg = Object.const_get(pkgName.capitalize)
pkg.name = pkgName

print pkg.version
