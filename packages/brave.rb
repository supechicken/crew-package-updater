require 'package'

class Brave < Package
  description 'Next generation Brave browser for macOS, Windows, Linux, Android.'
  homepage 'https://brave.com/'
  version '1.35.103'
  license 'MPL-2'
  compatibility 'x86_64'
  source_url 'https://github.com/brave/brave-browser/releases/download/v1.35.103/brave-browser-1.35.103-linux-amd64.zip'
  source_sha256 '98a9857a394383feeffa6862761b081f6a5ccf6bc73354d46c79c37e31bc0c75'

  depends_on 'gtk3'
  depends_on 'libcom_err'
  depends_on 'xdg_base'
  depends_on 'sommelier'

  def self.check
    system './brave', '--version'
  end

  def self.install
    FileUtils.mkdir_p "#{CREW_DEST_PREFIX}/bin"
    FileUtils.mkdir_p "#{CREW_DEST_PREFIX}/share/brave"
    FileUtils.cp_r '.', "#{CREW_DEST_PREFIX}/share/brave"
    FileUtils.ln_s "#{CREW_PREFIX}/share/brave/brave", "#{CREW_DEST_PREFIX}/bin/brave"
    FileUtils.ln_s CREW_LIB_PREFIX, "#{CREW_DEST_PREFIX}/share/#{ARCH_LIB}"
  end

  def self.check_update
    @_repo_url = 'https://brave-browser-apt-release.s3.brave.com'
    @_info = `curl -LSs '#{@_repo_url}/dists/stable/main/binary-amd64/Packages'`.split("\n\n").select do |pkginfo|
      pkginfo[/^Package: (.+)/, 1] == 'brave-browser'
    end

    @_latest_info = @_info.sort_by do |info|
      Gem::Version.new(info[/^Version: (.+)/, 1])
    end[-1]

    @_latest_ver = @_latest_info[/^Version: (.+)/, 1]

    return @_latest_info[/^Version: (.+)/, 1], "https://github.com/brave/brave-browser/releases/download/v#{@_latest_ver}/brave-browser-#{@_latest_ver}-linux-amd64.zip"
  end
end
