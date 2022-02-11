require 'package'

class Nano < Package
  description 'Nano\'s ANOther editor, an enhanced free Pico clone.'
  homepage 'https://www.nano-editor.org/'
  version '5.8'
  license 'GPL-3'
  compatibility 'all'
  source_url 'https://nano-editor.org/dist/v5/nano-5.8.tar.xz'
  source_sha256 'e43b63db2f78336e2aa123e8d015dbabc1720a15361714bfd4b1bb4e5e87768c'

  depends_on 'xdg_base'

  def self.patch
    system "sed -i '/SIGWINCH/d' src/nano.c"
  end

  def self.build
    system "#{CREW_ENV_OPTIONS} \
      ./configure #{CREW_OPTIONS} \
      --enable-threads=posix \
      --enable-nls \
      --enable-rpath \
      --enable-browser \
      --enable-color \
      --enable-comment \
      --enable-extra \
      --enable-help \
      --enable-histories \
      --enable-justify \
      --enable-libmagic \
      --enable-linenumbers \
      --enable-mouse \
      --enable-multibuffer \
      --enable-nanorc \
      --enable-operatingdir \
      --enable-speller \
      --enable-tabcomp \
      --enable-wordcomp \
      --enable-wrapping \
      --enable-utf8"
    system 'make'
    open('nanorc', 'w') do |f|
      f << "set constantshow\n"
      f << "set fill 72\n"
      f << "set historylog\n"
      f << "set multibuffer\n"
      f << "set nowrap\n"
      f << "set positionlog\n"
      f << "set historylog\n"
      f << "set quickblank\n"
      f << "set regexp\n"
      f << "set suspend\n"
    end
  end

  def self.install
    system 'make', "DESTDIR=#{CREW_DEST_DIR}", 'install-strip'
    system "install -Dm644 nanorc #{CREW_DEST_HOME}/.nanorc"
    FileUtils.mkdir_p "#{CREW_DEST_HOME}/.local/share"
    FileUtils.ln_sf("#{CREW_PREFIX}/share/nano", "#{CREW_DEST_HOME}/.local/share/")
  end

  def self.postinstall
    puts
    puts 'Personal configuration file is located in $HOME/.nanorc'.lightblue
    puts
  end

  def self.check_update
    @_html_url = 'https://nano-editor.org/dist'
    @_html = `curl -LSs '#{@_html_url}'`
    
    @_major_ver = @_html.scan(/href="v(.*?)\/"/).flatten.sort_by do |ver|
      Gem::Version.new(ver)
    end[-1]

    @_major_ver_html_url = "#{@_html_url}/v#{@_major_ver}"
    @_major_ver_html = `curl -LSs '#{@_major_ver_html_url}'`

    @_latest_ver = @_html.scan(/nano-(.*?).tar.xz/).flatten.sort_by do |ver|
      Gem::Version.new(ver)
    end[-1]

    return @_latest_ver, "#{@_major_ver_html_url}/nano-#{@_latest_ver}.tar.xz"
  end
end
