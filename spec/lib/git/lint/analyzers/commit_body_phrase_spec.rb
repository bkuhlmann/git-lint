# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitBodyPhrase do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

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

  describe "#valid?" do
    context "when valid" do
      let(:commit) { GitPlus::Commit[body_lines: ["Test."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with excluded word in body" do
      let(:commit) { GitPlus::Commit[body_lines: ["This will fail, obviously."]] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with excluded word in body (mixed case)" do
      let(:commit) { GitPlus::Commit[body_lines: ["This will fail, Obviously."]] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with excluded phrase in body" do
      let(:commit) { GitPlus::Commit[body_lines: ["This will fail, of course."]] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with excluded phrase in body (mixed case)" do
      let(:commit) { GitPlus::Commit[body_lines: ["This will fail, Of Course."]] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with default exclude list" do
      [
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
      ].each do |phrase|
        let(:commit) { GitPlus::Commit[body_lines: [phrase]] }

        it %(answers false for "#{phrase}") do
          expect(analyzer.valid?).to be(false)
        end
      end
    end

    context "with excluded word (mixed case)" do
      subject :analyzer do
        described_class.new GitPlus::Commit[body_lines: ["This will fail, basically."]]
      end

      let :configuration do
        Git::Lint::Configuration::Content[
          analyzers: [
            Git::Lint::Configuration::Setting[id: :commit_body_phrase, excludes: ["BasicaLLy"]]
          ]
        ]
      end

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with excluded phrase (mixed case)" do
      subject :analyzer do
        described_class.new GitPlus::Commit[body_lines: ["This will fail, of course."]]
      end

      let :configuration do
        Git::Lint::Configuration::Content[
          analyzers: [
            Git::Lint::Configuration::Setting[id: :commit_body_phrase, excludes: ["OF CoursE"]]
          ]
        ]
      end

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with excluded boundary word (regular expression)" do
      subject :analyzer do
        described_class.new GitPlus::Commit[body_lines: ["Just for test purposes."]]
      end

      let :configuration do
        Git::Lint::Configuration::Content[
          analyzers: [
            Git::Lint::Configuration::Setting[id: :commit_body_phrase, excludes: ["\\bjust\\b"]]
          ]
        ]
      end

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with excluded, embedded boundary word (regular expression)" do
      subject :analyzer do
        described_class.new GitPlus::Commit[body_lines: ["Adjusted for testing purposes."]]
      end

      let :configuration do
        Git::Lint::Configuration::Content[
          analyzers: [
            Git::Lint::Configuration::Setting[id: :commit_body_phrase, excludes: ["\\bjust\\b"]]
          ]
        ]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with excluded phrase (regular expression)" do
      subject :analyzer do
        described_class.new GitPlus::Commit[body_lines: ["This will fail, of course."]]
      end

      let :configuration do
        Git::Lint::Configuration::Content[
          analyzers: [
            Git::Lint::Configuration::Setting[
              id: :commit_body_phrase,
              excludes: ["(o|O)f (c|C)ourse"]
            ]
          ]
        ]
      end

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { GitPlus::Commit[body_lines: ["Test."]] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let :commit do
        GitPlus::Commit[
          body_lines: [
            "Obviously, this can't work.",
            "...and, of course, this won't work either."
          ]
        ]
      end

      it "answers issue hint" do
        expect(issue[:hint]).to eq(
          "Avoid: /absolutely/, /actually/, /all intents and purposes/, /along the lines/, " \
          "/at this moment in time/, /basically/, /each and every one/, /everyone knows/, " \
          "/fact of the matter/, /furthermore/, /however/, /in due course/, /in the end/, " \
          "/last but not least/, /matter of fact/, /obviously/, /of course/, /really/, " \
          "/simply/, /things being equal/, /would like to/, /\\beasy\\b/, /\\bjust\\b/, " \
          "/\\bquite\\b/, /as\\sfar\\sas\\s.+\\sconcerned/, /of\\sthe\\s(fact|opinion)\\sthat/."
        )
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
