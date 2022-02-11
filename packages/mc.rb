require 'package'

class Mc < Package
  description 'GNU Midnight Commander is a visual file manager'
  homepage 'http://midnight-commander.org/'
  version '4.8.27'
  license 'GPL-2'
  compatibility 'all'
  source_url 'https://github.com/MidnightCommander/mc.git'
  git_hashtag '4.8.27'

  depends_on 'glib' => :build
  depends_on 'aspell' => :build
  depends_on 'gpm'

  def self.build
    system '[ -x configure ] || NOCONFIGURE=1 ./autogen.sh'
    system "env CFLAGS='-pipe -flto=auto' CPPFLAGS='-pipe -flto=auto' \
      LDFLAGS='-flto=auto' \
      ./configure #{CREW_OPTIONS}"
    system 'make'
  end

  def self.install
    system 'make', "DESTDIR=#{CREW_DEST_DIR}", 'install'
  end

  def self.check_update
    @_latest_ver = @_latest_tag = `git ls-remote --tags https://github.com/MidnightCommander/mc.git` \
                                    .scan(/refs\/tags\/(\d[^\^\n]*)/).flatten.reject {|ver| ver =~ /pre/ } \
                                    .sort_by {|ver| Gem::Version.new(ver) } [-1]

    return @_latest_ver, @_latest_tag, git_tag: true
  end
end
