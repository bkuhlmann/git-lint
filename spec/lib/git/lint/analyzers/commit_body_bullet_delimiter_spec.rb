# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitBodyBulletDelimiter do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq("commit_body_bullet_delimiter")
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Body Bullet Delimiter")
    end
  end

  describe "#valid?" do
    context "with space after bullet" do
      let(:commit) { Gitt::Models::Commit[body_lines: ["- Test."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with indented bullet and trailing space" do
      let(:commit) { Gitt::Models::Commit[body_lines: ["  - test."]] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with repeated bullet" do
      let :commit do
        Gitt::Models::Commit[body_lines: ["--", "--test", " --test", "-- test"]]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with wrapped bullets" do
      let :commit do
        Gitt::Models::Commit[body_lines: ["*test*", "-test-"]]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "without space after bullet" do
      let(:commit) { Gitt::Models::Commit[body_lines: ["-Test."]] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with indented bullet without trailing space" do
      let(:commit) { Gitt::Models::Commit[body_lines: ["  -test."]] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
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
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { Gitt::Models::Commit[body_lines: []] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:commit) { Gitt::Models::Commit[body_lines: ["One.", "- Two.", "-three.", "*four."]] }

      it "answers issue hint" do
        expect(issue[:hint]).to eq("Use space after bullet.")
      end

      it "answers issue affected lines" do
        expect(issue[:lines]).to contain_exactly(
          {number: 5, content: "-three."},
          {number: 6, content: "*four."}
        )
      end
    end
  end
end
