CREW_LIBS = [ 'const', 'color', 'package_helpers', 'package' ]

def require (file)
  unless CREW_LIBS.include?( File.basename(file, '.rb') )
    return Kernel.require(file)
  end
end

CREW_LIBS.each do |lib|
  file = `curl -LSs 'https://raw.githubusercontent.com/skycocker/chromebrew/master/lib/#{lib}.rb'`
  if lib == 'const'
    file.gsub!(/LIBC_VERSION.*/, "LIBC_VERSION='2.x'")
    file.gsub!(/`LD_TRACE_LOADED_OBJECTS=1.*?`/, 'String.new')
  end
  eval file
end
