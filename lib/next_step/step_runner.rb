module NextStep
  module StepRunner

    # Pass a list of steps which are an array of callable objects (lambda, proc, etc)

    def run_steps(steps, errors=[])
      @step_errors = errors
      result = steps.each { |step| break false unless execute_step(step) }
      result && @step_errors.empty?
    end

    # a container for any errors encountered while running steps. 
    # Adding items to the container will result in the run_steps method
    # returning false indicating a failed attempt at running all the 
    # steps successfully
    def step_errors
      @step_errors ||= []
    end

    def safely(error=nil)
      yield if block_given?
      proceed
    rescue => e
      message = error ? error : e.message
      stop message
    end

    # Can be overridden to allow wrapping functionality around 
    # running a step or calling steps in different ways.
    # See NextStep::EventProcessor for an example
    def execute_step(step)
      result = step.call
      advances.each do |event|
        event.call(StepResult.new(:step, step_errors, result))
      end
      result
    end

    # Use this to send the step runner a halt and don't process anything else.
    def halt
      false
    end

    # Use stop to add an error and completely stop the steps from proceeding.
    def stop(message="")
      step_errors << message unless message.blank?
      false
    end

    # Use invalid to add an error but continue procesing other steps.
    # Eventual result will be false. This is good for a set of validations 
    # where you want to collect all the errors.
    def invalid(message="")
      step_errors << message
      true
    end

    def proceed
      true
    end

    # Allow a block to be called after each step is run
    def on_advance(&block)
      advances << block
    end

    def advances
      @advances ||= []
    end

  end
end
