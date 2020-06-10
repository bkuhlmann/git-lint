# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitBodyPhrase do
  subject(:analyzer) { described_class.new commit: commit, settings: settings }

  let(:body_lines) { ["This is an example of a commit message body."] }
  let(:status) { instance_double Process::Status, success?: true }
  let(:shell) { class_spy Open3, capture2e: ["", status] }

  let :commit do
    object_double Git::Lint::Commits::Saved.new(sha: "1", shell: shell), body_lines: body_lines
  end

  let(:excludes) { ["obviously", "of course"] }
  let(:settings) { {enabled: true, excludes: excludes} }

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_body_phrase)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Body Phrase")
    end
  end

  describe ".defaults" do
    # rubocop:disable RSpec/ExampleLength
    it "answers defaults" do
      expect(described_class.defaults).to eq(
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
      )
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe "#valid?" do
    it "answers true when valid" do
      expect(analyzer.valid?).to eq(true)
    end

    context "with excluded word (mixed case)" do
      let(:excludes) { ["BasicaLLy"] }
      let(:body_lines) { ["This will fail, basically."] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with excluded phrase (mixed case)" do
      let(:excludes) { ["OF CoursE"] }
      let(:body_lines) { ["This will fail, of course."] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with excluded boundary word (regular expression)" do
      let(:excludes) { ["\\bjust\\b"] }
      let(:body_lines) { ["Just for test purposes."] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with excluded, embedded boundary word (regular expression)" do
      let(:excludes) { ["\\bjust\\b"] }
      let(:body_lines) { ["Adjusted for testing purposes."] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with excluded phrase (regular expression)" do
      let(:excludes) { ["(o|O)f (c|C)ourse"] }
      let(:body_lines) { ["This will fail, of course."] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with excluded word in body" do
      let(:body_lines) { ["This will fail, obviously."] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with excluded word in body (mixed case)" do
      let(:body_lines) { ["This will fail, Obviously."] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with excluded phrase in body" do
      let(:body_lines) { ["This will fail, of course."] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with excluded phrase in body (mixed case)" do
      let(:body_lines) { ["This will fail, Of Course."] }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end

    context "with default exclude list" do
      defaults = [
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
        "easy",
        "just",
        "quite",
        "as far as I am concerned",
        "as far as I'm concerned",
        "of the fact that",
        "of the opinion that"
      ]

      defaults.each do |phrase|
        it %(answers false for "#{phrase}") do
          status = instance_double Process::Status, success?: true
          shell = class_spy Open3, capture2e: ["", status]
          commit = object_double Git::Lint::Commits::Saved.new(sha: "1", shell: shell),
                                 body_lines: [phrase]
          analyzer = described_class.new commit: commit

          expect(analyzer.valid?).to eq(false)
        end
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let :body_lines do
        [
          "Obviously, this can't work.",
          "...and, of course, this won't work either."
        ]
      end

      it "answers issue hint" do
        expect(issue[:hint]).to eq("Avoid: /obviously/, /of course/.")
      end

      it "answers issue lines" do
        expect(issue[:lines]).to eq(
          [
            {number: 2, content: "Obviously, this can't work."},
            {number: 3, content: "...and, of course, this won't work either."}
          ]
        )
      end
    end
  end
end
