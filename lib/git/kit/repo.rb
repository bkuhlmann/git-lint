# frozen_string_literal: true

module Git
  module Kit
    class Repo
      def initialize shell: Open3
        @shell = shell
      end

      def exist?
        shell.capture2e("git rev-parse --git-dir > /dev/null 2>&1")
             .then { |result, status| result && status.success? }
      end

      def branch_name
        shell.capture2e("git rev-parse --abbrev-ref HEAD | tr -d '\n'")
             .then { |result, _status| result }
      end

      def shas start: "master", finish: branch_name
        shell.capture2e(%(git log --pretty=format:"%H" #{start}..#{finish}))
             .then { |result, _status| result.split "\n" }
      end

      private

      attr_reader :shell
    end
  end
end
