require 'fileutils'

GH_TOKEN = ARGV[0]

File.foreach('log/modified_pkg', chomp: true) do |pkgFile|
  pkgName = File.basename(pkgFile, '.rb')
  new_branch_name = "update_#{pkgName}_#{`date '+%Y%m%d'`.chomp}"

  if system "git ls-remote --heads https://supechicken:#{GH_TOKEN}@github.com/supechicken/chromebrew | grep -vq 'update_#{pkgName}_.*'"
    Dir.mkdir '/tmp/crew_repo'

    Dir.chdir '/tmp/crew_repo' do
      system "git clone https://supechicken:#{GH_TOKEN}@github.com/supechicken/chromebrew ."
      system "git checkout -b '#{new_branch_name}'"
    end

    File.write( "/tmp/crew_repo/#{pkgFile}", File.read(pkgFile).sub(/\n^  def self.check_update.*^  end\n/m, '') )

    Dir.chdir '/tmp/crew_repo' do
      system 'git add packages/'
      system "git commit -m 'Update Checker'"
      system "git push origin #{new_branch_name}"
    end

    FileUtils.rm_rf '/tmp/crew_repo'
  end
end
