require 'package'

class Filezilla < Package
  description 'FileZilla Client is a free FTP solution.'
  homepage 'https://filezilla-project.org/'
  version '3.58.0'
  license 'GPL-2'
  compatibility 'aarch64,armv7l,x86_64'
  source_url 'https://download.filezilla-project.org/client/FileZilla_3.58.0_src.tar.bz2'
  source_sha256 'd0fe7f72e01f7742baa06466818b186e8e91fff62d6ee7b2f0e884b6b3385d88'

  depends_on 'dbus'
  depends_on 'gnome_icon_theme'
  depends_on 'hicolor_icon_theme'
  depends_on 'libfilezilla'
  depends_on 'libidn2'
  depends_on 'sqlite'
  depends_on 'wxwidgets'
  depends_on 'xdg_utils'
  depends_on 'libwebp'
  depends_on 'wayland'
  depends_on 'mesa'
  depends_on 'xcb_util'
  depends_on 'wxwidgets'

  def self.patch
    system 'filefix'
  end

  def self.build
    system "#{CREW_ENV_OPTIONS} ./configure #{CREW_OPTIONS} --disable-maintainer-mode --with-pugixml=builtin"
    system 'make'
  end

  def self.install
    system 'make', "DESTDIR=#{CREW_DEST_DIR}", 'install'
  end

  def self.check_update
    @_html_url = 'https://download.filezilla-project.org/client'
    @_html = `curl -LSs '#{@_html_url}'`
    @_latest_ver = @_html.scan(/<a href="(.+?_src\.tar\.bz2)"/).flatten.reject do |file|
      # reject beta/rc release
      file =~ /-(beta|rc)/
    end.sort_by do |file|
      Gem::Version.new(file[/FileZilla_(.+?)_src\.tar\.bz2/, 1])
    end[-1][/FileZilla_(.+?)_src\.tar\.bz2/, 1]
    
    return @_latest_ver, "#{@_html_url}/FileZilla_#{@_latest_ver}_src.tar.bz2"
  end
end
