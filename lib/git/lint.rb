# frozen_string_literal: true

require "zeitwerk"

Zeitwerk::Loader.new.then do |loader|
  loader.inflector.inflect "cli" => "CLI",
                           "sha" => "SHA",
                           "circle_ci" => "CircleCI",
                           "netlify_ci" => "NetlifyCI",
                           "travis_ci" => "TravisCI"
  loader.tag = "git-lint"
  loader.ignore "#{__dir__}/lint/rake"
  loader.push_dir "#{__dir__}/.."
  loader.setup
end

module Git
  # Main namespace.
  module Lint
  end
end
