require 'smugsync/version'
require 'bundler/setup'
require 'smile'
require 'open-uri'
require 'fileutils'

class Smugsync
  def initialize smug_obj
    @smug = smug_obj
  end

  def cpu_count
    return Java::Java.lang.Runtime.getRuntime.availableProcessors if defined? Java::Java
    return File.read('/proc/cpuinfo').scan(/^processor\s*:/).size if File.exist? '/proc/cpuinfo'
    require 'win32ole'
    WIN32OLE.connect("winmgmts://").ExecQuery("select * from Win32_ComputerSystem").NumberOfProcessors
  rescue LoadError
    Integer `sysctl -n hw.ncpu 2>/dev/null` rescue 1
  end

  def download photo, options={}
    options = Smile::ParamConverter.clean_hash_keys( options )

    params = @smug.default_params
    params.merge!( options ) if( options )
    @smug.logger.info( params.inspect )

    #uri = URI.join(photo.originalurl, '?', URI.encode_www_form(params))
    #uri = URI.join(photo.originalurl)
    uri = URI("#{photo.originalurl}?#{URI.encode_www_form(params)}")
    @smug.logger.info( photo.inspect )
    @smug.logger.info( uri.inspect )

    dest_file = photo.filename
    puts "Downloading #{dest_file}..."
    File.open(dest_file, 'wb') do |saved_file|
      # the following "open" is provided by open-uri
      open(uri, 'rb') do |read_file|
        saved_file.write read_file.read
      end
    end
  end
end
