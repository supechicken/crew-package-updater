require 'fileutils'
require_relative 'lib/wrapper'

def update_recipe(file, ver, url)
  sha256sum = `curl -LSs "#{url}" | sha256sum`[/[^ ]*/]

  content = File.read(file)
      
  content.sub!(/version .*/, "version '#{ver}'")
  content.sub!(/source_url .*/, "source_url '#{url}'")
  content.sub!(/source_sha256 .*/, "source_sha256 '#{sha256sum}'")

  File.write(file, content)
end

FileUtils.mkdir_p 'log/'
File.write 'log/check_time', Time.now.strftime("%Y-%m-%d %H:%M:%S")
File.write 'log/modified_pkg', ''
File.write 'log/update_available.md', ''

Dir.glob('packages/*.rb') do |pkg|
  require_relative pkg
  pkgName = File.basename(pkg, '.rb')
  @pkg = Object.const_get(pkgName.capitalize)

  pkg_ver = `ruby lib/get_crew_pkg_ver.rb #{pkgName}`
  latest_ver, source_url, options = @pkg.check_update

  abort if $?.exitstatus != 0

  puts <<~EOT.lightblue

    Package: #{pkgName}
    Current version: #{pkg_ver}
    Latest version: #{latest_ver}
  EOT

  next unless Gem::Version.new(latest_ver) > Gem::Version.new(pkg_ver)

  File.write 'log/modified_pkg', "#{pkg}\n", mode: 'a'
  File.write 'log/update_available.md', "- #{pkgName}: `#{pkg_ver}` => `#{latest_ver}`\n", mode: 'a'

  update_recipe(pkg, latest_ver, source_url, options)
end
