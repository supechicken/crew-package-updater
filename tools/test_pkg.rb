#!/usr/bin/env ruby
require 'fileutils'

REPO_URL = 'https://raw.githubusercontent.com/supechicken/crew-package-updater/main'
$result = {}

`curl -L #{REPO_URL}/log/modified_pkg`.each_line(chomp: true) do |pkgFile|
  puts "\e[1;34m""Working on #{pkgFile}""\e[0m"

  pkgName = File.basename(pkgFile, '.rb')

  system 'curl', '-L', "#{REPO_URL}/#{pkgFile}", '-o', "#{CREW_PACKAGES_PATH}/#{pkgName.rb}"

  system "yes | crew install #{pkgName}"

  `crew files #{pkgName} | grep "^/usr/local/bin/.*"`.each_line(chomp: true) do |exec|
    if system(exec, '--version')
      $result.merge({ pkgName => true })
    else
      $result.merge({ pkgName => false })
    end
  end
end

$result.each_pair do |pkgName, result|
  if result == true
    puts "\e[1;32m""#{pkgName}: Working!""\e[0m".lightgreen
  else
    puts "\e[1;31m""#{pkgName}: Failed!""\e[0m".lightred
  end
end
