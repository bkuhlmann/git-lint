# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitBodyBulletCapitalization do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq("commit_body_bullet_capitalization")
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Body Bullet Capitalization")
    end
  end

  describe "#valid?" do
    context "with uppercase bullet" do
      let(:commit) { Gitt::Models::Commit[body_lines: ["- Test."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with no bullet lines" do
      let(:commit) { Gitt::Models::Commit[body_lines: ["test."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with empty lines" do
      let(:commit) { Gitt::Models::Commit[body_lines: []] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with lowercase bullet (no trailing space)" do
      let(:commit) { Gitt::Models::Commit[body_lines: ["-test."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with capitalized ASCII Doc link" do
      let(:commit) { Gitt::Models::Commit[body_lines: ["- link:https://test.com[Test]"]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with lowercase bullet" do
      let(:commit) { Gitt::Models::Commit[body_lines: ["- test."]] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with lowercase bullet (indented)" do
      let(:commit) { Gitt::Models::Commit[body_lines: ["  - test."]] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { Gitt::Models::Commit[body_lines: ["- Test."]] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let :commit do
        Gitt::Models::Commit[body_lines: ["Examples:", "- one.", "- Two.", "* three."]]
      end

      it "answers issue hint" do
        expect(issue[:hint]).to eq("Capitalize first word.")
      end

      it "answers issue affected lines" do
        expect(issue[:lines]).to contain_exactly(
          {number: 4, content: "- one."},
          {number: 6, content: "* three."}
        )
      end
    end
  end
end
