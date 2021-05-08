# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Reporters::Style do
  subject(:reporter) { described_class.new analyzer }

  describe "#to_s" do
    let :analyzer do
      instance_spy Git::Lint::Analyzers::CommitAuthorEmail,
                   class: class_spy(
                     Git::Lint::Analyzers::CommitAuthorEmail,
                     label: "Commit Author Email"
                   ),
                   severity: severity,
                   issue: issue
    end

    let(:severity) { :error }

    context "with warning" do
      let(:severity) { :warn }
      let(:issue) { {hint: "A test hint."} }

      it "answers analyzer label and issue hint" do
        expect(reporter.to_s).to eq("\e[33m  Commit Author Email Warning. A test hint.\n\e[0m")
      end
    end

    context "with error" do
      let(:severity) { :error }
      let(:issue) { {hint: "A test hint."} }

      it "answers analyzer label and issue hint" do
        expect(reporter.to_s).to eq("\e[31m  Commit Author Email Error. A test hint.\n\e[0m")
      end
    end

    context "with unknown severity" do
      let(:severity) { :bogus }
      let(:issue) { {hint: "A test hint."} }

      it "answers analyzer label and issue hint" do
        expect(reporter.to_s).to eq("\e[37m  Commit Author Email. A test hint.\n\e[0m")
      end
    end

    context "with issue lines" do
      let :issue do
        {
          hint: "A test hint.",
          lines: [
            {number: 1, content: "Curabitur eleifend wisi iaculis ipsum."},
            {number: 3, content: "Ipsum eleifend wisi iaculis curabitur."}
          ]
        }
      end

      it "answers analyzer label, issue label, issue hint, and issue lines" do
        expect(reporter.to_s).to eq(
          "\e[31m  Commit Author Email Error. A test hint.\n" \
          "    Line 1: \"Curabitur eleifend wisi iaculis ipsum.\"\n" \
          "    Line 3: \"Ipsum eleifend wisi iaculis curabitur.\"\n\e[0m" \
        )
      end
    end
  end
end
