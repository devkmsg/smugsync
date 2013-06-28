#!/usr/bin/env ruby

require 'bundler'
Bundler.setup

require 'thor'
require 'smugsync'
require 'smile'
#require_relative '../../smile/lib/smile'

include Smile
include FileUtils

class SmugThorCommand < Thor

  desc 'keyword_search', 'Download photos by keyword'
  method_option :nickname, :desc => 'Smugmug nickname', :required => true
  method_option :username, :desc => 'Smugmug email address', :required => true
  method_option :login_password, :desc => 'Smugmug login', :required => true
  method_option :api_key, :desc => 'Smugmug api key', :required => true
  method_option :site_password, :desc => 'Smugmug protected album password' 
  #method_option :albums, :type => :array, :desc => 'Smugmug albums', :required => true
  method_option :keyword, :desc => 'Keyword', :required => true
  method_option :dest_dir, :desc => 'Download destination directory', :required => true
  def keyword_search
    Smile::Base.configure do |config|
      config.logger_on = false 
      config.api_key = options[:api_key]
    end

    mkdir_p options[:dest_dir] unless File.directory? options[:dest_dir]
    cd options[:dest_dir]

    smug = Smile::Smug.new
    sync = Smugsync.new(smug)
    smug.auth(options[:username], options[:login_password])
    albums = smug.albums :nick_name => options[:nickname] 
    require 'pp'
    #pp albums
    #albums = albums.collect { |a| a if options[:albums].include? a.title }.compact!
    download_list = []
    albums.each do |album|
      if album.password.empty?
        photos = album.photos :nick_name => options[:nickname] 
      else
        photos = album.photos :password => options[:site_password], :nick_name => options[:nickname] 
      end
    
      photos = photos.collect { |p| p if p.keywords == options[:keyword]} 
      photos = photos.reject { |p| p.nil? }
      download_list << photos unless photos.empty?
      download_list = download_list.flatten
    end
   
 
    download_list.each do |photo|
      sync.download photo
    end
  end
end

SmugThorCommand.start
