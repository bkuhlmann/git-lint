# frozen_string_literal: true

RSpec.shared_examples_for "a squash commit" do
  it "answers true when subject includes squash! prefix" do
    allow(commit).to receive(:subject).and_return("squash! Added test file.")
    expect(commit.squash?).to eq(true)
  end

  it "answers false when subject excludes squash! prefix" do
    allow(commit).to receive(:subject).and_return("Added test file.")
    expect(commit.squash?).to eq(false)
  end
end
