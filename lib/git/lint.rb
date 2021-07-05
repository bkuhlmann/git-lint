# frozen_string_literal: true

require "zeitwerk"
require "git_plus"

loader = Zeitwerk::Loader.new
loader.inflector.inflect "cli" => "CLI",
                         "sha" => "SHA",
                         "circle_ci" => "CircleCI",
                         "netlify_ci" => "NetlifyCI",
                         "travis_ci" => "TravisCI"
loader.push_dir "#{__dir__}/.."
loader.ignore "#{__dir__}/lint/rake/setup.rb"
loader.setup

# Main namespace.
module Git
  module Lint
  end
end
