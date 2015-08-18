module NextStep
  module StepRunner

    # Pass a list of steps which are an array of callable objects (lambda, proc, etc)

    def run_steps(steps, errors=[])
      @step_errors = errors
      result = steps.each { |step|  break false unless process_result(execute_step(step), step) }
      result && @step_errors.empty?
    end

    # a container for any errors encountered while running steps. 
    # Adding items to the container will result in the run_steps method
    # returning false indicating a failed attempt at running all the 
    # steps successfully
    def step_errors
      @step_errors ||= []
    end

    def step_results 
      @step_results ||= []
    end

    def safely(description)
      yield if block_given?
      proceed
    rescue => e
      stop_with_exception description, e
    end

    # Can be overridden to allow wrapping functionality around 
    # running a step or calling steps in different ways.
    # See NextStep::EventProcessor for an example
    def execute_step(step)
      result = case 
      when step.respond_to?(:call) then step.call
      when step.kind_of?(Symbol) then send(step)
      else
        fail "Invalid step. Must be a callable object or symbol method reference."
      end
      result
    end

    def process_result(result, step)
      result.step = step.to_s
      advances.each do |callable|
        callable.call(result)
      end
      step_results << result
      result.continue
    end

    # Use this to send the step runner a halt and don't process anything else.
    def halt
      StepResult.new(false)
    end

    # Use stop to add an error and completely stop the steps from proceeding.
    def stop(message="")
      step_errors << message unless message.nil? || message.empty?
      StepResult.new(false, message)
    end

    # Use invalid to add an error but continue procesing other steps.
    # Eventual result will be false. This is good for a set of validations 
    # where you want to collect all the errors.
    def invalid(message)
      step_errors << message
      StepResult.new(true, message)
    end

    def proceed
      StepResult.new(true)
    end

    # Allow a block to be called after each step is run
    def on_advance(&block)
      advances << block
    end

    def advances
      @advances ||= []
    end

    def stop_with_exception(description, exception)
      message = "Exception when #{description}: #{exception.message}"
      step_errors << message
      StepResult.new(false, message, exception)
    end

  end
end
