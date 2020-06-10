# frozen_string_literal: true

module Git
  module Lint
    module Analyzers
      class CommitBodyPhrase < Abstract
        # rubocop:disable Metrics/MethodLength
        def self.defaults
          {
            enabled: true,
            severity: :error,
            excludes: [
              "absolutely",
              "actually",
              "all intents and purposes",
              "along the lines",
              "at this moment in time",
              "basically",
              "each and every one",
              "everyone knows",
              "fact of the matter",
              "furthermore",
              "however",
              "in due course",
              "in the end",
              "last but not least",
              "matter of fact",
              "obviously",
              "of course",
              "really",
              "simply",
              "things being equal",
              "would like to",
              /\beasy\b/,
              /\bjust\b/,
              /\bquite\b/,
              /as\sfar\sas\s.+\sconcerned/,
              /of\sthe\s(fact|opinion)\sthat/
            ]
          }
        end
        # rubocop:enable Metrics/MethodLength

        def valid?
          commit.body_lines.all? { |line| !invalid_line? line }
        end

        def issue
          return {} if valid?

          {
            hint: %(Avoid: #{filter_list.to_hint}.),
            lines: affected_commit_body_lines
          }
        end

        protected

        def load_filter_list
          Kit::FilterList.new settings.fetch(:excludes)
        end

        def invalid_line? line
          line.downcase.match? Regexp.new(
            Regexp.union(filter_list.to_regexp).source,
            Regexp::IGNORECASE
          )
        end
      end
    end
  end
end
