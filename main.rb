require 'fileutils'
require_relative 'lib/wrapper'

def update_recipe(file, ver, url_or_git_tag, **options)
  content = File.read(file)
  content.sub!(/version .*/, "version '#{ver}'")

  if option[:git_tag]
    content.sub!(/(git_hashtag|git_branch) .*/, "git_hashtag '#{url_or_git_tag}'")
  else
    sha256sum = `curl -LSs "#{url_or_git_tag}" | sha256sum`[/[^ ]*/]

    content.sub!(/source_url .*/, "source_url '#{url_or_git_tag}'")
    content.sub!(/source_sha256 .*/, "source_sha256 '#{sha256sum}'")
  end

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
  latest_ver, source_url_or_git_tag, options = @pkg.check_update

  abort if $?.exitstatus != 0

  puts <<~EOT.lightblue

    Package: #{pkgName}
    Current version: #{pkg_ver}
    Latest version: #{latest_ver}
  EOT

  next unless Gem::Version.new(latest_ver) > Gem::Version.new(pkg_ver)

  File.write 'log/modified_pkg', "#{pkg}\n", mode: 'a'
  File.write 'log/update_available.md', "- #{pkgName}: `#{pkg_ver}` => `#{latest_ver}`\n", mode: 'a'

  update_recipe(pkg, latest_ver, source_url_or_git_tag, options)
end
