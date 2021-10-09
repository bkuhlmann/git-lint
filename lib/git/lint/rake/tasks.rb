# frozen_string_literal: true

require "rake"
require "git/lint"

module Git
  module Lint
    module Rake
      # Defines and installs Rake tasks for use in downstream projects.
      class Tasks
        include ::Rake::DSL

        def self.setup = new.install

        def initialize shell: CLI::Shell.new
          @shell = shell
        end

        def install
          desc "Run Git Lint"
          task :git_lint do
            shell.call ["--analyze"]
          end
        end

        private

        attr_reader :shell
      end
    end
  end
end
