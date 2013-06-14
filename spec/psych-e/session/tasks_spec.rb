require 'spec_helper'

describe Psych::E::Session::Tasks do
  let(:a_session) { double(:session) }
  subject { described_class.new(a_session) }
  # after(:each) { subject.terminate }

  it "should react on add keys" do
    subject.mailbox << Psych::E::Session::Event.new(:add, "data")
    expect(subject).to have_key("data")
  end

  it "should add and delete keys" do
    subject
    ["foo", "bar", "bla"].each {|key|
      subject.mailbox << Psych::E::Session::Event.new(:add, key)
      
    }
    # subject.mailbox << Psych::E::Session::Event.new(:done, "bar")
    sleep 3
    expect(subject.tasks_set).to eq({})
    expect(subject.current_actor).to have_key("bar")
    expect(subject.current_actor).to_not have_key("foo")
  end

end
