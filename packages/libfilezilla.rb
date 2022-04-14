require 'package'

class Libfilezilla < Package
  description 'libfilezilla is a small and modern C++ library, offering some basic functionality to build high-performing, platform-independent programs.'
  homepage 'https://lib.filezilla-project.org/'
  version '0.37.1'
  license 'GPL-2+'
  compatibility 'aarch64,armv7l,x86_64'
  source_url 'https://download.filezilla-project.org/libfilezilla/libfilezilla-0.37.1.tar.bz2'
  source_sha256 'f9446c0936ecc6f6172f8b944536f0708d54c27bfd1fa0e62e1410c6f7cb33e8'

  depends_on 'p11kit'

  def self.patch
    system 'filefix'
  end

  def self.build
    system "./configure #{CREW_OPTIONS}"
    system 'make'
  end

  def self.check
    system 'make check'
  end

  def self.install
    system 'make', "DESTDIR=#{CREW_DEST_DIR}", 'install'
  end

  def self.check_update
    @_html_url = 'https://download.filezilla-project.org/libfilezilla'
    @_html = `curl -LSs '#{@_html_url}'`
    @_latest_ver = @_html.scan(/<a href="libfilezilla-(.+?)\.tar\.bz2"/).flatten.sort_by do |ver|
      Gem::Version.new(ver)
    end[-1]
    
    return @_latest_ver, "#{@_html_url}/libfilezilla-#{@_latest_ver}.tar.bz2"
  end
end
