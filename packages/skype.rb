require 'package'

class Skype < Package
  description 'Skype is a telecommunications application that specializes in providing video chat and voice calls between devices'
  homepage 'https://www.skype.com/'
  version '8.81.0.268'
  license 'Skype-TOS'
  compatibility 'x86_64'
  source_url 'https://repo.skype.com/deb/pool/main/s/skypeforlinux/skypeforlinux_8.81.0.268_amd64.deb'
  source_sha256 '32a5cb2be01d6244154de4e3ba5f43aeeefce7dec5b93851515abbff2f456145'

  depends_on 'gtk3'
  depends_on 'sommelier'

  def self.check
    system './usr/bin/skypeforlinux', '--version'
  end

  def self.install
    FileUtils.mkdir_p CREW_DEST_PREFIX
    FileUtils.ln_s "./skypeforlinux", 'usr/bin/skype'
    FileUtils.mv Dir['usr/*'], CREW_DEST_PREFIX
  end
  
  def self.check_update
    @_repo_url = 'https://repo.skype.com/deb'
    @_info = `curl -LSs '#{@_repo_url}/dists/stable/main/binary-amd64/Packages'`.split("\n\n").select do |pkginfo|
      pkginfo[/^Package: (.+)/, 1] == 'skypeforlinux'
    end

    @_latest_info = @_info.sort_by do |info|
      Gem::Version.new(info[/^Version: (.+)/, 1])
    end[-1]

    return @_latest_info[/^Version: (.+)/, 1], "#{@_repo_url}/#{@_latest_info[/^Filename: (.*)/, 1]}"
  end
end
