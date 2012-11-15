# -*- encoding: utf-8 -*-
require File.expand_path('../lib/smugsync/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andrew Thompson"]
  gem.email         = ["netengr2009@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = "https://github.com/netengr2009/smugsync"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "smugsync"
  gem.require_paths = ["lib"]
  gem.version       = Smugsync::VERSION
end
