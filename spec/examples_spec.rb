require 'spec_helper'
describe 'resolution examples' do

  before(:all) do
    Psych::E.configure do |c|
      c.root = File.expand_path("fixtures/", __dir__)
    end
  end

  # NOTE: reset configuration
  after(:all) { Psych::E.reset }

  context "when no external reference is present" do
    let(:some_standard_yml) { <<YAML
---
some:
  nice: map
  and:
    - 1
    - ordinary
    - sequence
YAML
    }
    let(:its_ruby_counterpart) {
      {"some" => {"nice" => "map", "and" => [1, "ordinary", "sequence"]}}
    }

    it "just should behave as Psych::load" do
      expect(Psych::E.load some_standard_yml).to eq its_ruby_counterpart
    end
  end

  context "resolving referenced yaml and emitting ruby" do
    context "with references pointing the local file system" do
      let(:some_yaml) { <<YAML
---
foo:
  mar: giass
  bang: !ref "/mowgli/caz"
YAML
      }

      let(:expected_resolved) {
        {"foo" => {
            "mar" => "giass",
            "bang" => {
              "bar" => "mega",
              "cazz" => ["some", "nice", "nietzsche"]}
          }
        }
      }

      let(:resolved) { Psych::E.load(some_yaml) }
      example "load yaml string" do
        expect(resolved).to eq(expected_resolved)
      end
    end

    context "nested fs resolution" do
      let(:some_yaml) {
        <<-YAML
---
foo:
  bang: !ref "first/second"
  mar: kant
YAML
      }
      let(:resolved) {{
          "foo" => {
            "bang" => {
              "what" => "a",
              "beautiful" => ["day", "to", {
                                "have" => {
                                  "a" => "swim",
                                  "with" => "you"
                                }
                              }]
            },
            "mar" => "kant"
          }

        }}
      example "load yaml string" do
        Psych::E.load(some_yaml).should eq(resolved)
      end
    end
  end

end
