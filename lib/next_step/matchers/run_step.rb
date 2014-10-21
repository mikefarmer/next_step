module NextStep::Matchers
  class RunStep
    include RSpec::Matchers::Composable

    def initialize(step)
      @step = step
      @terminator = nil
    end

    def matches?(obj)
      @called_event = false
      if !@terminator
        @msg = "Must supply proceed, invalid, halt, or stop to the matcher" 
        return false
      end

      if @event_name
        obj.on(@event_name) do |result|
          @called_event = true
        end
      end


      @step_result = obj.send(@step.to_sym)
      if ! @step_result.kind_of?(NextStep::StepResult)
        fail "Expected the step to return a StepResult. Make sure you are using proceed, stop, halt, invalid, or safely."
      end

      @after_payload = obj.payload if @before_payload

      @message = @step_result.message if @expected_message

      if @expected_message && @message.nil?
        @message = obj.step_errors.first
      end

      conditions.each do |c|
        unless c[:condition].call
          @msg = c[:msg].call
          @not_msg = c[:not_msg].call
          return false
        end
      end
      return true
    end

    def with_payload(payload)
      fail "Cannot call with_payload with using stop, halt, or invalid." if @terminator != :proceed
      @before_payload = payload
      conditions << {
        condition: ->{ values_match?(@before_payload, @after_payload) },
        msg: ->{ "Expected the payload to be #{@before_payload || 'nil'} but was #{@after_payload || 'nil'}" },
        not_msg: ->{"Expected the payload to not be #{@after_payload || 'nil'}" }
      }
      self
    end

    def with_message(message)
      fail "Cannot call with_message using 'proceed'. Use stop or invalid instead." if [:proceed, :halt].include? @terminator
      @expected_message = message
      conditions << {
        condition: ->{ values_match?(@expected_message, @message) },
        msg: ->{ "Expected the message to be '#{@expected_message || 'nil'}' but got '#{@message || 'nil'}'" },
        not_msg: ->{ "Expected the message to not be '#{@expected_message || 'nil'}'" }
      }
      self
    end

    def and
      self
    end

    def proceed
      @terminator = :proceed
      conditions << {
        condition: ->{ @step_result.continue == true },
        msg: ->{ "Expected the step to proceed but it stopped. Message: #{@message}" },
        not_msg: ->{ "Expected the step to stop but it proceeded. Message: #{@message}" }
      }
      self
    end

    def stop
      @terminator = :stop
      conditions << {
        condition: ->{ @step_result.continue == false },
        msg: ->{ "Expected the step to stop but it proceeded." },
        not_msg: ->{ "Expected the step to proceed but it stopped." }
      }
      self
    end

    def halt
      @terminator = :halt
      conditions << {
        condition: ->{ @step_result.continue == false && @step_result.message.nil? },
        msg: ->{ "Expected the step to halt but it proceeded." },
        not_msg: ->{ "Expected the step to proceed but it halted." }
      }
      self
    end

    def invalid
      @terminator = :invalid
      conditions << {
        condition: ->{ @step_result.continue && @step_result.message },
        msg: ->{ "Expected the step to be invalid but it proceeded." },
        not_msg: ->{ "Expected the step to proceed but it was invalid." }
      }
      self
    end
    alias_method :invalidate, :invalid

    def with_event(event_name)
      @event_name = event_name
      conditions << {
        condition: ->{ @called_event },
        msg: ->{ "Expected the event '#{event_name}' to be called but it wasn't." },
        not_msg: ->{ "Expected the event '#{event_name}' to not be called but it was." }
      }
      self
    end

    def failure_message
      @msg || "There was a problem getting the outcome of the step: #{@step}. Could possibly be that the step didn't end with proceed or stop."
    end
    
    def failure_message_when_negated
      @not_msg || "There was a problem getting the outcome of the step: #{@step}. Negation only works with simple matchers of just proceed or stop."
    end

    private

    def conditions
      @conditions ||= []
    end

  end
end
