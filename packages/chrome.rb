require 'package'

class Chrome < Package
  description 'Google Chrome is a fast, easy to use, and secure web browser.'
  homepage 'https://www.google.com/chrome'
  version '98.0.4758.80-1'
  license 'google-chrome'
  compatibility 'x86_64'
  source_url 'https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_98.0.4758.80-1_amd64.deb'
  source_sha256 'f1ddb0c3b10b2c345f24b2774a882ee28564c87788f78502f4d03de70a814b5c'

  depends_on 'nspr'
  depends_on 'cairo'
  depends_on 'gtk3'
  depends_on 'expat'
  depends_on 'cras'
  depends_on 'sommelier'

  def self.check
    system './opt/google/chrome/chrome', '--version'
  end

  def self.install
    FileUtils.mkdir_p "#{CREW_DEST_PREFIX}/bin"

    FileUtils.mv 'usr/share', CREW_DEST_PREFIX
    FileUtils.mv 'opt/google/chrome', "#{CREW_DEST_PREFIX}/share"

    FileUtils.ln_s "../share/chrome/google-chrome", "#{CREW_DEST_PREFIX}/bin/google-chrome-stable"
    FileUtils.ln_s "../share/chrome/google-chrome", "#{CREW_DEST_PREFIX}/bin/google-chrome"
  end

  def self.check_update
    @_repo_url = 'https://dl.google.com/linux/chrome/deb'
    @_info = `curl -LSs '#{@_repo_url}/dists/stable/main/binary-amd64/Packages'`.split("\n\n").select do |pkginfo|
      pkginfo[/^Package: (.+)/, 1] == 'google-chrome-stable'
    end

    @_latest_info = @_info.sort_by do |info|
      Gem::Version.new(info[/^Version: (.+)/, 1])
    end[-1]

    return @_latest_info[/^Version: (.+)/, 1], "#{@_repo_url}/#{@_latest_info[/^Filename: (.*)/, 1]}"
  end
end
