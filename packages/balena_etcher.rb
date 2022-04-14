require 'package'

class Balena_etcher < Package
  description 'Flash OS images to SD cards & USB drives, safely and easily.'
  homepage 'https://www.balena.io/etcher/'
  @_ver = '1.7.8'
  version @_ver
  license 'Apache-2.0'
  compatibility 'x86_64, i686'

  source_url ({
    x86_64: "https://github.com/balena-io/etcher/releases/download/v#{@_ver}/balenaEtcher-#{@_ver}-x64.AppImage",
      i686: "https://github.com/balena-io/etcher/releases/download/v#{@_ver}/balenaEtcher-#{@_ver}-ia32.AppImage"
  })

  source_sha256 ({
    x86_64: '1341852897149ff2d738dcb9f68f141dcff4bce9c6b9d33add453c2d0706f1d9',
      i686: '5f3614fa1f80f2729a5c447148b12dfc1292cc812071c8c3af45d8cb24b8c52e'
  })

  no_compile_needed

  depends_on 'libgconf'
  depends_on 'alsa_lib'
  depends_on 'atk'
  depends_on 'cairo'
  depends_on 'cups'
  depends_on 'dbus'
  depends_on 'expat'
  depends_on 'fontconfig'
  depends_on 'freetype'
  depends_on 'gcc'
  depends_on 'gdk_pixbuf'
  depends_on 'glib'
  depends_on 'gtk2'
  depends_on 'xzutils'
  depends_on 'libnotify'
  depends_on 'npsr'
  depends_on 'nss'
  depends_on 'pango'
  #depends_on 'polkit'
  depends_on 'sommelier'

  def self.build
    @_wrapper = <<~EOF
      #!/usr/bin/env bash
      # sudo wrapper for balena_etcher
      exec sudo -E LD_LIBRARY_PATH="${LD_LIBRARY_PATH}" balena-etcher-electron
    EOF
  end

  def self.install
    FileUtils.mkdir_p "#{CREW_DEST_PREFIX}/bin"
    FileUtils.mkdir_p "#{CREW_DEST_PREFIX}/share/balena-etcher"
    FileUtils.mv Dir['*'], "#{CREW_DEST_PREFIX}/share/balena-etcher"
    FileUtils.ln_sf "#{CREW_DEST_PREFIX}/share/balena-etcher/balena-etcher-electron", "#{CREW_DEST_PREFIX}/bin/balena-etcher-electron"
    File.write "#{CREW_DEST_PREFIX}/bin/balena-etcher", @_wrapper, perm: 0o755
  end

  def self.postinstall
    puts
    puts "To get started, type 'balena-etcher'.".lightblue
    puts
  end

  def self.check_update
    @_latest_ver = `curl -IsS https://github.com/balena-io/etcher/releases/latest`[/^location.*tag\/v(.*?)$/, 1]
    return @_latest_ver, "https://github.com/balena-io/etcher/releases/download/v#{@_latest_ver}/balenaEtcher-#{@_latest_ver}-x64.AppImage"
  end
end
