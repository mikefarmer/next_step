require 'spec_helper'

module NextStep

  RSpec.describe StepRunner do

    it "proceeds through all the steps" do
      runner = TestStepRunner.new
      expect(runner.run).to be true
    end

    it "stops on a given step with a message" do
      runner = TestStepRunner.new :one
      expect(runner.run).to be false
      expect(runner.step_errors).to eql ["stopped on one"]
    end

    it "halts without a message" do
      runner = TestStepRunner.new :two
      expect(runner.run).to be false
      expect(runner.step_errors).to be_empty
    end

    it "returns a valid step result on proceed" do
      runner = TestStepRunner.new
      result = runner.test_one
      expect(result).to be_kind_of StepResult
      expect(result.continue).to be true
      expect(result.message).to be_nil
    end

    it "returns a valid step result on stop" do
      runner = TestStepRunner.new :one
      result = runner.test_one
      expect(result).to be_kind_of StepResult
      expect(result.continue).to be false
      expect(result.message).to eql "stopped on one"
    end

    it "returns a valid step result on halt" do
      runner = TestStepRunner.new :two
      result = runner.test_two
      expect(result).to be_kind_of StepResult
      expect(result.continue).to be false
      expect(result.message).to be_nil
    end

    it "returns a valid step result on invalid" do
      runner = TestStepRunner.new :three
      result = runner.test_three
      expect(result).to be_kind_of StepResult
      expect(result.continue).to be true
      expect(result.message).to eql "stopped on three"
    end

    it "runs an advance block when each step is run" do
      runner = TestStepRunner.new
      step_results = []
      runner.on_advance do |r|
        step_results << r
      end
      runner.run
      expect(step_results.count).to eql 4
      expect(step_results.last.continue).to be true
    end

    it "safely executes a method" do
      runner = TestStepRunner.new
      result = runner.test_four
      expect(result).to be_kind_of StepResult
      expect(result.continue).to be true
      expect(result.message).to be_nil
    end

    it "safely recovers from an exception when specified" do
      runner = TestStepRunner.new :four
      result = runner.test_four
      expect(result).to be_kind_of StepResult
      expect(result.continue).to be false
      expect(result.message).to eql :error
      expect(result.exception.message).to eql "stopped on four"
    end

    it "supports a list of symbols as steps" do
      runner = TestStepRunner.new
      expect(runner.run_symbols).to be true
    end

  end
end

