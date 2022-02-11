#!/usr/bin/env ruby
require 'fileutils'
require_relative '/usr/local/lib/crew/lib/color.rb'

REPO_URL = 'https://raw.githubusercontent.com/supechicken/crew-package-updater/main'
$result = {}

def system(*args)
  Kernel.system(*args, exception: true)
end

`curl -L #{REPO_URL}/log/modified_pkg`.each_line(chomp: true) do |pkgFile|
  begin
    pkgName = File.basename(pkgFile, '.rb')
    puts "Working on #{pkgFile}".lightblue

    system 'curl', '-L', "#{REPO_URL}/#{pkgFile}", '-o', "/usr/local/lib/crew/#{pkgFile}"
    system "yes | crew install #{pkgName}"

    `crew files #{pkgName} | grep "^/usr/local/bin/.*"`.each_line(chomp: true) do |exec|
      puts "Testing #{exec}".yellow
      system(exec, '--version')
    end
    
    $result.merge!({ pkgName => true })
  rescue
    $result.merge!({ pkgName => false })
  end
end

print "\n\n\n\n"
puts '===> Test result <==='
$result.each_pair do |pkgName, result|
  if result == true
    puts "#{pkgName}: " + 'Working!'.lightgreen
  else
    puts "#{pkgName}: " + 'Failed!'.lightred
  end
end
