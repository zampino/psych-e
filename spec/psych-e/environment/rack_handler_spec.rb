require 'spec_helper'
require File.expand_path("app.rb", FIXTURES_ROOT)

describe Psych::E::Environment::RackHandler do
  context "handling hybrid Filesystem + rack yaml serving" do

    let(:options) { double(:fake_options,
                           :root => FIXTURES_ROOT,
                           :mount => {"/some_path" => App }
                           )}

    subject { Psych::E::Environment::RackHandler.new(options) }

    it { should respond_to(:get) }

    example "fetching file from filesystem " do
      expect(subject.get("first")).to be_an_instance_of(String)
      expect(subject.get("first")).to eq("wow:\n  what: a\n  nice:\n    - res\n    - o\n    - !ref lution")
      expect(subject.get("first")).to eq subject.get("/first")
    end

    example "fetching file through a custom rack app" do
      expect(subject.get("/some_path/for_yaml")).to eq("---\n:james:\n  :doesnt:\n    :like: Jaegermeister\n    :but: Averna a lot\n")
    end

  end
end
