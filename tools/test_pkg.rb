#!/usr/bin/env ruby
require 'fileutils'
require_relative '/usr/local/lib/crew/lib/color.rb'

REPO_URL = 'https://raw.githubusercontent.com/supechicken/crew-package-updater/main'
$result = {}

FileUtils.mkdir_p '/tmp/build'
Dir.chdir '/tmp/build'

system 'yes | crew install buildessential'

`curl -LsS #{REPO_URL}/log/modified_pkg`.each_line(chomp: true) do |pkgFile|
  begin
    pkgName = File.basename(pkgFile, '.rb')
    puts "Working on #{pkgFile}".lightblue

    # remove target package before installing the newer version one
    system "crew remove #{pkgName}"

    system 'curl', '-LsS', "#{REPO_URL}/#{pkgFile}", '-o', "/usr/local/lib/crew/#{pkgFile}"
    system "yes | crew build #{pkgName}", exception: true

    $result.merge!({ pkgName => true })
  rescue
    $result.merge!({ pkgName => false })
  end
end

File.open('/tmp/test_result', 'w') do |io|
  io.puts '===> Test result <==='
  $result.each_pair do |pkgName, result|
    if result == true
      io.printf "%-20s: %s\n", pkgName, 'Working!'.lightgreen
    else
      io.printf "%-20s: %s\n", pkgName, 'Failed!'.lightred
    end
  end
end
