require 'spec_helper'

describe Psych::E do

  it { should respond_to :resolve }
  it { should respond_to :configure }

  specify {
    subject.resolve("/some/path/to/yaml#and/some/1/fragment", emit: :json, foo: "bar").should be_true
  }

  describe "::resolve" do
    
    context "method call chain" do
      let(:fake_supervisor) {
        stub(:on_tasks_completed)
      }
      
      specify {
        Psych::E::Configuration.should_receive(:merge).with({emit: :ruby}).and_call_original
        Psych::E::Supervisor.should_receive(:new).with("/bla/bla/", {emit: :ruby}).and_return(fake_supervisor)

        Psych::E::Resolution.should_receive(:new).and_call_original


        subject.resolve("/bla/bla/", emit: :ruby)
      }

    end


  end



  describe "::configure" do
    specify "how the configuration should look like now" do
      Psych::E::Configuration.should_receive(:instance).twice.and_call_original

      Psych::E.configure do |config|
        config.emit :json
        config.environment_base = "public/schemas"
      end

      Psych::E::Configuration.instance.to_h.should == {
        emit: :json,
        environment_base: "public/schemas"
      }
      
    end
  end
end
