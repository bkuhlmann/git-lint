# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitBodyBulletDelimiter do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_body_bullet_delimiter)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Body Bullet Delimiter")
    end
  end

  describe "#valid?" do
    context "with space after bullet" do
      let(:commit) { GitPlus::Commit[body_lines: ["- Test bullet."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with indented bullet and trailing space" do
      let(:commit) { GitPlus::Commit[body_lines: ["  - test bullet."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with repeated bullet" do
      let(:commit) { GitPlus::Commit[body_lines: ["--", "--test", " --test", "-- test"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "without space after bullet" do
      let(:commit) { GitPlus::Commit[body_lines: ["-Test bullet."]] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with indented bullet without trailing space" do
      let(:commit) { GitPlus::Commit[body_lines: ["  -test bullet."]] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with no bullet lines" do
      let(:commit) { GitPlus::Commit[body_lines: ["a test line."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with empty lines" do
      let(:commit) { GitPlus::Commit[body_lines: []] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { GitPlus::Commit[body_lines: []] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let :commit do
        GitPlus::Commit[
          body_lines: ["A normal line.", "- A valid bullet line.", "-An invalid bullet line."]
        ]
      end

      it "answers issue hint" do
        expect(issue[:hint]).to eq("Use space after bullet.")
      end

      it "answers issue affected lines" do
        expect(issue[:lines]).to contain_exactly(number: 4, content: "-An invalid bullet line.")
      end
    end
  end
end
