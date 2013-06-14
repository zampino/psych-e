require 'spec_helper'

describe Psych::E::Configuration do
  subject { Psych::E::Configuration.instance }

  describe "its defaults" do
    its(:emit) { should be(:ruby) }
    its("root.to_s") { should eq(Dir.getwd) }
  end

  describe "its (unique) instance" do
    it { should respond_to :to_h }
    it "should embrace the singleton pattern" do
      expect(subject).to be(Psych::E::Configuration.instance)
    end
  end

  describe "::update_with" do
    specify { expect(subject.class).to respond_to(:update_with) }
  end

  describe "#mount" do
    let(:map) { { "some/path" => double("App") } }
    it "set the table :mount value in no = fashion" do
      subject.mount map
      expect(subject.mount).to eq(map)
    end
  end
end

describe Psych::E::SessionOptions do
  let(:local_options) { {emit: emit} }
  let(:session_options) { Psych::E::Configuration.update_with(local_options) }

  describe "translating options" do
    context "emitting ruby" do
      let(:emit) { :ruby }

      before {
        Psych::E::Configuration.instance.this_setting = "that value"
        Psych::E::Configuration.instance.paranoid = true
      }
      specify "it should just store allowed values" do
        expect(session_options.emit).to be(:to_ruby)
        expect(session_options.root.to_s).to eq(Dir.getwd)
        expect(session_options.this_setting).to eq(nil)
        expect(session_options.paranoid).to be_true
      end
    end
  end
end
