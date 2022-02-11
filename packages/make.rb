require 'package'

class Make < Package
  description 'GNU Make is a tool which controls the generation of executables and other non-source files of a program from the program\'s source files.'
  homepage 'https://www.gnu.org/software/make/'
  version '4.3'
  license 'GPL-3+'
  compatibility 'all'
  source_url 'https://ftpmirror.gnu.org/gnu/make/make-4.3.tar.lz'
  source_sha256 'de1a441c4edf952521db30bfca80baae86a0ff1acd0a00402999344f04c45e82'


  def self.build
    system "./configure #{CREW_OPTIONS} --enable-cross-guesses=conservative"
    system './build.sh'
  end

  def self.install
    system './make', "DESTDIR=#{CREW_DEST_DIR}", 'install'
  end

  def self.check
    # Give it several tries since output-sync fails rarely
    system 'for i in {1..3}; do make check; done'
  end

  def self.check_update
    @_pkg = 'make'
    @_suffix = '.tar.lz'

    @_html_url = "https://ftpmirror.gnu.org/gnu/#{@_pkg}"
    @_html = `curl -LSs '#{@_html_url}'`
    @_latest_ver = @_html.scan(/<a href="#{@_pkg}-(.+?)#{@_suffix.tr('.', '\.')}"/).flatten.sort_by do |ver|
      Gem::Version.new(ver)
    end[-1]
    
    return @_latest_ver, "#{@_html_url}/#{@_pkg}-#{@_latest_ver}#{@_suffix}"
  end
end
