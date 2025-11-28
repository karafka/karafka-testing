# frozen_string_literal: true

RSpec.describe_current do
  subject(:proxy) { described_class.new(minitest_example) }

  let(:minitest_example) do
    double('Minitest::Test').tap do |example|
      allow(example).to receive(:_karafka_consumer_for)
      allow(example).to receive(:_karafka_produce)
      allow(example).to receive(:_karafka_produce_to)
      allow(example).to receive(:_karafka_produced_messages).and_return([])
      allow(example).to receive(:_karafka_consumer_messages).and_return([])
    end
  end

  describe '#initialize' do
    it 'stores the minitest example' do
      expect(proxy.instance_variable_get(:@minitest_example)).to eq(minitest_example)
    end
  end

  describe '#consumer_for' do
    it 'delegates to _karafka_consumer_for' do
      proxy.consumer_for(:test_topic)

      expect(minitest_example).to have_received(:_karafka_consumer_for).with(:test_topic)
    end

    it 'passes all arguments' do
      proxy.consumer_for(:test_topic, :test_group)

      expect(minitest_example).to have_received(:_karafka_consumer_for)
        .with(:test_topic, :test_group)
    end
  end

  describe '#produce' do
    it 'delegates to _karafka_produce' do
      proxy.produce('payload')

      expect(minitest_example).to have_received(:_karafka_produce).with('payload')
    end

    it 'passes all arguments' do
      proxy.produce('payload', partition: 1)

      expect(minitest_example).to have_received(:_karafka_produce)
        .with('payload', partition: 1)
    end
  end

  describe '#produce_to' do
    let(:consumer_instance) { double('consumer') }

    it 'delegates to _karafka_produce_to' do
      proxy.produce_to(consumer_instance, 'payload')

      expect(minitest_example).to have_received(:_karafka_produce_to)
        .with(consumer_instance, 'payload')
    end

    it 'passes all arguments including metadata' do
      proxy.produce_to(consumer_instance, 'payload', partition: 2)

      expect(minitest_example).to have_received(:_karafka_produce_to)
        .with(consumer_instance, 'payload', partition: 2)
    end
  end

  describe '#produced_messages' do
    it 'delegates to _karafka_produced_messages' do
      proxy.produced_messages

      expect(minitest_example).to have_received(:_karafka_produced_messages)
    end

    it 'returns the messages from the example' do
      messages = [{ topic: 'test', payload: 'data' }]
      allow(minitest_example).to receive(:_karafka_produced_messages).and_return(messages)

      expect(proxy.produced_messages).to eq(messages)
    end
  end

  describe '#consumer_messages' do
    it 'delegates to _karafka_consumer_messages' do
      proxy.consumer_messages

      expect(minitest_example).to have_received(:_karafka_consumer_messages)
    end

    it 'returns the messages from the example' do
      messages = %w[message1 message2]
      allow(minitest_example).to receive(:_karafka_consumer_messages).and_return(messages)

      expect(proxy.consumer_messages).to eq(messages)
    end
  end
end
