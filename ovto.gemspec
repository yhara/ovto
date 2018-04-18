require "#{__dir__}/lib/ovto/version"

Gem::Specification.new do |spec|
  spec.name          = "ovto"
  spec.version       = Ovto::VERSION
  spec.authors       = ["Yutaka HARA"]
  spec.email         = ["yutaka.hara+github@gmail.com"]

  spec.summary       = %q{Simple client-side framework for Opal}
  spec.description   = %q{Simple client-side framework for Opal}
  spec.homepage      = "https://github.com/yhara/ovto"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "opal", '~> 0.11.0'
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
end
