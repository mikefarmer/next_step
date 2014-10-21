module NextStep
  module Pipeline

    def set_initial_payload(payload)
      @next_payload = payload
    end
    
    # Override the execute step from StepRunner to allow
    # passing payloads from one step to another.
    def execute_step(step)
      result = step.call(next_payload)
      @next_payload = result.payload
      messages << result.message if result.message
      result.continue
    end

    # Proceed to next step
    def proceed(payload, message=nil)
      PipelineResult.new(true, message, payload)
    end

    # Stop with an error
    def stop(payload, message)
      step_errors << message
      PipelineResult.new(false, message, payload)
    end
    alias_method :invalid, :stop

    # Stop without an error
    def halt(payload)
      PipelineResult.new(false, "Premature halt", payload)
    end

    # Shortcut step to only proceed if an exception is not thrown
    def safely(payload, error=nil)
      result_payload = block_given? ? yield(payload) : payload
      proceed result_payload
    rescue => e
      message = error ? error : e.message
      stop payload, message
    end

    def final_payload
      next_payload
    end


    private

    def next_payload
      @next_payload || []
    end

    def messages
      @messages ||= []
    end

  end
end
