require 'spec_helper'

describe Psych::E::Session do
  before(:all) { Psych::E::Session.include SessionTestSupport }

  let(:some_uri) { "/some/path/" }
  let(:some_options) { {some: :option} }
  let(:an_instance) { Psych::E::Session.new } #(some_uri, some_options) }
  subject { an_instance }
  let(:its_tasks) { an_instance.instance_variable_get "@tasks" }

  describe "session tasks" do
    subject { its_tasks }
    it { is_expected.to be_an_instance_of(Psych::E::Session::Tasks) }
  end

  describe "#enqueue_task"

  describe "#task_done"

  describe "#on_tasks_completed" do

    context "when there are pending tasks" do
      it "should wait for all tasks to be completed before yielding the block" do
        subject.enqueue_task :one
        subject.enqueue_task :two
        expect(its_tasks.keys).to eq([:one, :two])
        subject.async.complete_deferred(:two, :one, wait_time: 1)
        subject.on_tasks_completed do
          expect(its_tasks.keys).to be_empty
        end
      end

      context "when there is no tasks enqueued" do
        it "should yield the block immediately" do
          expect { |block|
            subject.on_tasks_completed &block
          }.to yield_control
        end

        it "should yield with no arguments" do
          expect { |block|
            subject.on_tasks_completed &block
          }.to yield_with_no_args
        end

      end
    end
  end
end
