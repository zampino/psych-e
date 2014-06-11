require 'spec_helper'

describe Psych::E do
  it { is_expected.to respond_to :resolve }
  it { is_expected.to respond_to :configure }
  it { is_expected.to respond_to :load }
  it { is_expected.to respond_to :load_file }

  describe "::load" do
    after { subject.load 'yaml', foo: "bar", ban: "zan" }
    specify "method call" do
      expect(subject).to receive(:resolve).
        with(".", body: 'yaml', emit: :ruby, foo: "bar", ban: "zan")
    end
  end

  describe "::load_file" do
    after { subject.load_file "yaml", foo: "bar", ban: "zan" }
    specify "method call" do
      expect(subject).to receive(:open).with('yaml').
        and_return double('io', read: 'yaml')
      expect(subject).to receive(:resolve).
        with(".", body: 'yaml', emit: :ruby, foo: "bar", ban: "zan")
    end
  end

  describe "::resolve" do
    let(:fake_session) { double(:session) }
    let(:fake_options) { OpenStruct.new(emit: :format) }
    let(:fake_home) { double(:home) }
    let(:fake_resolution) { double(:resolution, fetch_home: fake_home) }

    before {
      allow(fake_session).to receive(:on_tasks_completed).and_yield # fake_session
    }

    specify "meethod call chain" do
      expect(Psych::E::Configuration).to receive(:update_with).
        with(some: "option").and_return fake_options
      expect(Psych::E::Session).to receive(:new).
        and_return(fake_session)
      expect(Psych::E::Resolution).to receive(:new).
        with('uri', fake_session, body: 'body', options: fake_options).
        and_return(fake_resolution)
      expect(fake_home).to receive(:format).and_return :result

      expect(subject.resolve("uri", body: "body", some: "option")).to equal :result
    end
  end

  describe "::configure" do
    let(:config_instance) { double("config instance") }
    specify "method call" do
      expect(Psych::E::Configuration).to receive(:instance).
        and_return config_instance

      expect(config_instance).to receive(:this).with(:with_that)

      Psych::E.configure do |config|
        config.this :with_that
      end
    end
  end
end
