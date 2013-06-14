require 'spec_helper'

describe Psych::E do
  it { should respond_to :resolve }
  it { should respond_to :configure }
  it { should respond_to :load }
  it { should respond_to :load_file }

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
    let(:fake_session) {
      fake_session = double()
      allow(fake_session).to receive(:on_tasks_completed).and_yield fake_session
    }

    let(:fake_home) { double("home") }
    let(:fake_resolution) { double(fetch_home: fake_home) }
    
    specify "meethod call chain" do
      expect(Psych::E::Configuration).to receive(:update_with).
        with(some: "option").and_return({emit: :format})

      expect(Psych::E::Supervisor).to receive(:new).
        with("uri", {emit: :format}).and_return(fake_session)

      expect(Psych::E::Resolution).to receive(:new).
        with('uri', fake_session, body: 'body').and_return(fake_resolution)

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

  describe "example of resolutions" do
    before {
      Psych::E.configure do |c|
        c.root= FIXTURES_ROOT
      end
    }

    example "of resolution" do
      expect(subject.load_file("/mowgli/caz.yml")).to be_true
    end
  end
end
