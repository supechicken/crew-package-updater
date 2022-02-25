require 'package'

class Opera < Package
  description "Opera is a multi-platform web browser based on Chromium and developed by Opera Software."
  homepage 'https://www.opera.com/'
  version '84.0.4316.21'
  license 'OPERA-2018'
  compatibility 'x86_64'
  source_url 'https://get.opera.com/pub/opera/desktop/84.0.4316.21/linux/opera-stable_84.0.4316.21_amd64.deb'
  source_sha256 '08429477642565025ba413b5b78a0a9b277eba13e208e63e797b52ad97fbe5ee'

  depends_on 'gtk3'
  depends_on 'gsettings_desktop_schemas'
  depends_on 'harfbuzz'
  depends_on 'graphite'
  depends_on 'cras'
  depends_on 'libcom_err'
  depends_on 'sommelier'

  def self.check
    system './lib/x86_64-linux-gnu/opera/opera', '--version'
  end

  def self.install
    # llvm-strip doesn't works with opera
    ENV['CREW_NOT_STRIP'] = '1'

    # Since opera puts the executable in a location that is not in the path,
    # we need to link it to bin directory.
    FileUtils.ln_sf "#{CREW_PREFIX}/share/x86_64-linux-gnu/opera/opera", 'bin/opera'

    # Move lib subfolder to the share directory.
    FileUtils.mv 'lib/x86_64-linux-gnu/', 'share/'
    FileUtils.rm_rf 'lib/'

    FileUtils.mkdir_p CREW_DEST_PREFIX
    FileUtils.mv Dir['*'], CREW_DEST_PREFIX
  end

  def self.postinstall
    puts
    print 'Set Opera as your default browser? [Y/n]: '
    case STDIN.getc
    when "\n", 'Y', 'y'
      Dir.chdir("#{CREW_PREFIX}/bin") do
        FileUtils.ln_sf "#{CREW_LIB_PREFIX}/opera/opera", 'x-www-browser'
      end
      puts 'Opera is now your default browser.'.lightgreen
    else
      puts 'No change has been made.'.orange
    end
    puts "\nType 'opera' to get started.\n".lightblue
  end

  def self.remove
    Dir.chdir("#{CREW_PREFIX}/bin") do
      if File.exist?('x-www-browser') and File.symlink?('x-www-browser') and \
        File.realpath('x-www-browser') == "#{CREW_PREFIX}/share/x86_64-linux-gnu/opera/opera"
        FileUtils.rm 'x-www-browser'
      end
    end
  end

  def self.check_update
    @_repo_url = 'https://deb.opera.com/opera'
    @_info = `curl -LSs '#{@_repo_url}/dists/stable/non-free/binary-amd64/Packages'`.split("\n\n").select do |pkginfo|
      pkginfo[/^Package: (.+)/, 1] == 'opera-stable'
    end

    @_latest_info = @_info.sort_by do |info|
      Gem::Version.new(info[/^Version: (.+)/, 1])
    end[-1]

    @_latest_ver = @_latest_info[/^Version: (.+)/, 1]

    return @_latest_info[/^Version: (.+)/, 1], "https://get.opera.com/pub/opera/desktop/#{@_latest_ver}/linux/opera-stable_#{@_latest_ver}_amd64.deb"
  end
end
