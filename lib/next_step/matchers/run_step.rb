module NextStep::Matchers
  class RunStep
    include RSpec::Matchers::Composable

    def initialize(step)
      @step = step
      @expecting_stop = false
      @expecting_proceed = false
    end

    def matches?(obj)
      @called_event = false
      if !@expecting_stop && !@expecting_proceed
        @msg = "Must supply proceed or stop to the matcher" 
        return false
      end

      if @event_name
        obj.on(@event_name) do |result|
          @called_event = true
        end
      end

      obj.on_advance do |result|
        @reason = result.reason
        @payload = result.payload
      end


      if @before_payload
        @event_result = obj.send(@step.to_sym, @before_payload)
      else
        @event_result = obj.send(@step.to_sym)
      end

      if @expected_reason.present? && @reason.blank?
        @reason = obj.step_errors.first
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
      fail "Cannot call with_payload with using 'stop'. Use with_reason instead." if @expecting_stop
      @before_payload = payload
      conditions << {
        condition: ->{ values_match?(@after_payload, @payload) },
        msg: ->{ "Expected the payload to be #{@after_payload || 'nil'} but was #{@payload || 'nil'}" },
        not_msg: ->{"Expected the payload to not be #{@after_payload || 'nil'}" }
      }
      self
    end

    def with_reason(reason)
      fail "Cannot call with_reason using 'proceed'. Use with_payload instead." if @expecting_proceed
      @expected_reason = reason
      conditions << {
        condition: ->{ values_match?(@expected_reason, @reason) },
        msg: ->{ "Expected the reason to be #{@expected_reason || 'nil'} but got #{@reason || 'nil'}" },
        not_msg: ->{ "Expected the reason to not be #{@expected_reason || 'nil'}" }
      }
      self
    end

    def and
      self
    end

    def proceed
      @expecting_proceed = true
      conditions << {
        condition: ->{ @event_result == true },
        msg: ->{ "Expected the step to proceed but it stopped. Reason: #{@reason}" },
        not_msg: ->{ "Expected the step to stop but it proceeded. Reason: #{@reason}" }
      }
      self
    end

    def stop
      @expecting_stop = true
      conditions << {
        condition: ->{ @event_result == false },
        msg: ->{ "Expected the step to stop but it proceeded." },
        not_msg: ->{ "Expected the step to proceed but it stopped." }
      }
      self
    end

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
      @not_msg || "There was a problem getting the outcome of the step: #{@step}. Could possibly be that the step didn't end with proceed or stop."
    end

    private

    def conditions
      @conditions ||= []
    end

  end
end
