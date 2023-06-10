# frozen_string_literal: true

require "git/lint"
require "rake"

module Git
  module Lint
    module Rake
      # Registers Rake tasks for use.
      class Register
        include ::Rake::DSL

        def self.call = new.call

        def initialize shell: CLI::Shell.new
          @shell = shell
        end

        def call
          desc "Run Git Lint"
          task(:git_lint) { shell.call %w[analyze --branch] }
        end

        private

        attr_reader :shell
      end
    end
  end
end
