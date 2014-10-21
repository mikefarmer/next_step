require "spec_helper"

module NextStep
  RSpec.describe EventProcessor do

    it "allows a specific event to be specified" do
      runner = EventStepRunner.new
      fired = false
      runner.on :test_one do |r, e|
        fired = true
        expect(r.continue).to be true
        expect(e).to eql :test_one
      end

      expect(runner.run([:test_one])).to be true
      expect(fired).to be true
    end

    it "allows multiple blocks per event" do
      runner = EventStepRunner.new
      count = 0
      runner.on(:test_one) { count += 1 }
      runner.on(:test_one) { count += 1 }

      expect(runner.run([:test_one])).to be true
      expect(count).to eql 2
    end

    it "fails if an event is fired and not captured" do
      runner = EventStepRunner.new
      expect { runner.run([:test_one])}.to raise_error EventMissingError
    end

    it "allows a general event for all missing events" do
      runner = EventStepRunner.new
      fired = false
      runner.on_missing { fired = true }

      expect(runner.run).to be true
      expect(fired).to be true
    end

    it "allows a general event to be fired for each event run" do
      runner = EventStepRunner.new
      fired = false
      runner.on_advance { fired = true }

      expect(runner.run).to be true
      expect(fired).to be true
    end

    it "fires an exception event when an exception is hit" do
      runner = EventStepRunner.new :four
      exception = nil
      runner.on(:exception) { |r| exception = r.exception }

      result = runner.test_four
      expect(result.continue).to be false
      expect(result.message).to eql :error
      expect(exception.message).to eql "stopped on four"
    end

    it "fires an event when stopped" do
      runner = EventStepRunner.new :one
      fired = false
      runner.on(:stopped) { fired = true }

      expect(runner.run).to be false
      expect(fired).to be true
    end

    it "fires an event when halted" do
      runner = EventStepRunner.new :two
      fired = false
      runner.on(:halted) do |r|
        fired = true
        expect(r.continue).to be false
        expect(r.message).to be_nil

      end

      expect(runner.run [:test_two] ).to be false
      expect(fired).to be true
    end

    it "fires an event when invalid" do
      runner = EventStepRunner.new :three
      fired = false
      runner.on(:invalid) do |r|
        fired = true
        expect(r.continue).to be true
        expect(r.message).to eql "stopped on three"

      end

      expect(runner.run [:test_three] ).to be false
      expect(fired).to be true
    end

  end
end
