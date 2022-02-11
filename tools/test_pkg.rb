#!/usr/bin/env ruby
require 'fileutils'
require_relative '/usr/local/lib/crew/lib/color.rb'

REPO_URL = 'https://raw.githubusercontent.com/supechicken/crew-package-updater/main'
$result = {}

def system(*args)
  Kernel.system(*args, exception: true)
end

system 'crew install buildessential'

`curl -LsS #{REPO_URL}/log/modified_pkg`.each_line(chomp: true) do |pkgFile|
  begin
    pkgName = File.basename(pkgFile, '.rb')
    puts "Working on #{pkgFile}".lightblue

    # remove target package before installing the newer version one
    system "crew remove #{pkgName}"

    system 'curl', '-LsS', "#{REPO_URL}/#{pkgFile}", '-o', "/usr/local/lib/crew/#{pkgFile}"
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
