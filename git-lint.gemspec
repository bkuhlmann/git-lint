# frozen_string_literal: true

require_relative "lib/git/lint/identity"

Gem::Specification.new do |spec|
  spec.name = Git::Lint::Identity::NAME
  spec.version = Git::Lint::Identity::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors = ["Brooke Kuhlmann"]
  spec.email = ["brooke@alchemists.io"]
  spec.homepage = "https://www.alchemists.io/projects/git-lint"
  spec.summary = "A command line interface for linting Git commits."
  spec.license = "Apache-2.0"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/bkuhlmann/git-lint/issues",
    "changelog_uri" => "https://www.alchemists.io/projects/git-lint/changes.html",
    "documentation_uri" => "https://www.alchemists.io/projects/git-lint",
    "source_code_uri" => "https://github.com/bkuhlmann/git-lint"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = "~> 3.0"
  spec.add_dependency "git_plus", "~> 0.5"
  spec.add_dependency "pastel", "~> 0.7"
  spec.add_dependency "refinements", "~> 8.0"
  spec.add_dependency "runcom", "~> 7.0"
  spec.add_dependency "thor", "~> 0.20"

  spec.files = Dir["lib/**/*"]
  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.executables << "git-lint"
  spec.require_paths = ["lib"]
end
