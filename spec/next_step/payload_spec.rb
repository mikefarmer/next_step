require 'spec_helper'

TestStepRunner.class_eval do
  include NextStep::Payload

  def modify_one
    @payload += 1
    proceed
  end

  def modify_two
    @payload += 2
    proceed
  end

end

module NextStep

  RSpec.describe Payload do
    it "sets a payload instance variable" do
      runner = TestStepRunner.new
      runner.set_initial_payload(0)
      expect(runner.payload).to eql 0
    end

    it "allows the steps to modify the payload" do
      runner = TestStepRunner.new
      runner.set_initial_payload(0)
      runner.run_symbols([:modify_one, :modify_two])
      expect(runner.payload).to eql 3
    end

    it "saves the payload for each step in the step result" do
      runner = TestStepRunner.new
      runner.set_initial_payload(0)
      runner.run_symbols([:modify_one, :modify_two])
      
      first_result = runner.step_results.first
      last_result = runner.step_results.last

      expect(first_result.payload).to eql 1
      expect(last_result.payload).to eql 3
    end

    it "returns the final payload" do
      runner = TestStepRunner.new
      runner.set_initial_payload(0)
      runner.run_symbols([:modify_one, :modify_two])
      expect(runner.final_payload).to eql 3
    end
  end
end
