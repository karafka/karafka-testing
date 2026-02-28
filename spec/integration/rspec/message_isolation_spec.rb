# frozen_string_literal: true

require_relative "../rspec_helper"

RSpec.describe "message isolation between examples" do
  include Karafka::Testing::RSpec::Helpers

  subject(:consumer) { karafka.consumer_for(:other_topic) }

  it "starts with no messages (first example)" do
    expect(karafka.produced_messages).to be_empty
    expect(karafka.consumer_messages).to be_empty
    karafka.produce('{"leak":"test"}')
  end

  it "starts with no messages (second example)" do
    expect(karafka.produced_messages).to be_empty
    expect(karafka.consumer_messages).to be_empty
  end
end
