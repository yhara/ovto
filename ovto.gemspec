require "#{__dir__}/lib/ovto/version"

Gem::Specification.new do |spec|
  spec.name          = "ovto"
  spec.version       = Ovto::VERSION
  spec.authors       = ["Yutaka HARA"]
  spec.email         = ["yutaka.hara+github@gmail.com"]

  spec.summary       = %q{Simple client-side framework for Opal}
  spec.description   = %q{Ovto is a client-side framework for Opal. You can write single-page apps with Ruby.}
  spec.homepage      = "https://github.com/yhara/ovto"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/}) || f == "book/README.md"
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "opal", '>= 0.11', '< 2'
  spec.add_dependency "thor", '~> 0.20'
  spec.add_dependency "rack", '~> 2.0'
end
