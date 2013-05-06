#!/usr/bin/env rake
require "bundler/gem_tasks"

#require 'bundler'
require 'rake/testtask'
#Bundler::GemHelper.install_tasks

SMUGMUG_VERSION = '1.3.0'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'spec'
  test.pattern = './spec/**/*_spec.rb'
  test.verbose = true
end
task :default => :test

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -r ./lib/smugsync.rb"
end

def parse_build_content response_body
  build_content = response_body.match(/^(buildContent\()(.+)(\);)$/m)[2]
  JSON.parse(build_content)
end

desc 'Generate Smugmug connector model file'
task :gen_smug_model do
  require 'faraday'
  require 'typhoeus'
  require 'json'

  conn = Faraday.new(:url => 'http://api.smugmug.com') do |faraday|
    faraday.request  :url_encoded             # form-encode POST params
    faraday.response :logger                  # log requests to STDOUT
    faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
  end

  response = conn.get do |req|
    req.url '/services/api/json/1.3.0/'
    req.params = { 'method' => 'smugmug.reflection.getGroupedMethods',
      'Pretty' => '1', 'Callback' => 'buildContent' }
  end

  # Parse buildContent as JSON
  build_content = parse_build_content(response.body)['Groups']
  model = []

  HYDRA = Typhoeus::Hydra.new(:max_concurrency => 10)

  build_content.each do |lib|
    methods = []
    lib['Methods'].each do |method|
      conn = Faraday.new(:url => 'http://api.smugmug.com', :parallel_manager => HYDRA) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter :typhoeus
      end

      conn.in_parallel do
        response = conn.get do |req|
          req.url '/services/api/json/1.3.0/'
          req.params = { 'method' => 'smugmug.reflection.getMethodInfo',
            'method' => 'smugmug.reflection.getMethodInfo',
            'MethodName' => method['Name'], 'Pretty' => '1', 'Callback' => 'buildContent' }
        end
      end

      build_content = parse_build_content(response.body)
      method['MethodInfo'] = build_content
      methods << method
    end
    model << { 'Name' => lib['Name'], 'Methods' => methods }
  end

  Dir.mkdir 'build' unless Dir.exists? 'build'
  File.open("build/smugmug_#{SMUGMUG_VERSION}.model", 'w') { |file| file.write(model) }
end
