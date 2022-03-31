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
    x86_64: 'b2432729ad79e6aa1d6292465db065b078b627c5ec6ddedea8580434088cb74f',
      i686: 'c9a2c976f0edff0521c71b9e4e948dc6f133749cd7e60ffc3796a6743d17e841'
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
      exec sudo -E LD_LIBRARY_PATH=${LD_LIBRARY_PATH} balena-etcher-electron
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
end
