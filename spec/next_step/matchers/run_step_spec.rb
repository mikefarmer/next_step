require 'spec_helper'

module NextStep
  RSpec.describe Matchers::RunStep do
    include NextStep::Matchers

    context "StepRunner" do
      it "allows using run_step for proceed" do
        r = TestStepRunner.new
        expect(r).to run_step(:test_one).and.proceed
      end

      it "allows using run_step for stop" do
        r = TestStepRunner.new :one
        expect(r).to run_step(:test_one).and.stop
        expect(r).to_not run_step(:test_two).and.stop
      end

      it "allows using step_run for stop and seeing a message" do
        r = TestStepRunner.new :one
        expect(r).to run_step(:test_one).and.stop.with_message "stopped on one"
      end

      it "wont allow with_message to be used with proceed" do
        r = TestStepRunner.new
        expect {
          expect(r).to run_step(:test_one).and.proceed.with_message "stopped on one"
        }.to raise_error
      end

      it "allows using step_run for halt" do
        r = TestStepRunner.new :two
        expect(r).to run_step(:test_two).and.halt
      end

      it "allows using step_run for invalid" do
        r = TestStepRunner.new :three
        expect(r).to run_step(:test_three).and.invalid.with_message "stopped on three"
      end
    end

    context "EventProcessor" do
      it "allows you to ensure an event is called" do
        r = EventStepRunner.new
        expect(r).to run_step(:test_one).and.proceed.with_event(:test_one)
      end

      it "allows ensuring an event is called with a message" do
        r = EventStepRunner.new :one
        expect(r).to run_step(:test_one).and.stop.with_event(:stopped).with_message "stopped on one"
      end

      it "allows checking the message for invalid steps" do
        r = EventStepRunner.new :three
        expect(r).to run_step(:test_three).and.invalidate.with_event(:invalid).with_message "stopped on three"
      end

    end

    context "Payload" do

      TestStepRunner.class_eval do
        include NextStep::Payload

        def modify_step
          @payload << " world"
          proceed
        end
      end
      
      it "allows checking the payload" do
        r = TestStepRunner.new
        r.set_initial_payload "hello"
        expect(r).to run_step(:modify_step).and.proceed.with_payload("hello world")
      end

    end
    
  end
end
