
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "uri_s3/version"

Gem::Specification.new do |spec|
  spec.name          = "uri_s3"
  spec.version       = S3Uri::VERSION
  spec.authors       = ["Scott Brickner"]
  spec.email         = ["scottb@mercuryanalytics.com"]

  spec.summary       = "URI class for parsing s3 URIs."
  spec.homepage      = "https://github.com/mercuryanalytics/uri_s3"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk-s3", "~> 1"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
end
