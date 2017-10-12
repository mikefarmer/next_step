module NextStep
  # module used for processing a series of events
  #
  #  Include this in your class and you can do things like:
  #
  #  on :success do |result|
  #    if result.reason == :error
  #      ... do something
  #    else
  #      ... do something else
  #    end
  #
  #    puts result.message
  #  end
  #
  #  fire :success
  #
  #  or
  #
  #  When used with the StepRunner, allows the steps to fire events
  #  that are then handled by the blocks using the `on` method
  #
  #  The Event processor is useful for communicating the status of steps as they run
  #  back to the caller of the object.
  #
  #  For just executing a series of steps without events, use the StepRunner.
  #  If you need to send back a status, or execute code outside of the object when
  #  certain states are met or messages need to be communicated, then use
  #  the EventProcessor for that.
  #
  #

  module EventProcessor

    attr_reader :last_event_fired

    def on(*event_handlers, &block)
      event_handlers.each do |event|
        events[event.to_sym] ||= []
        events[event.to_sym] << {type: :block, block: block}
      end
      self
    end

    # Run the block when an event is raised that is not being captured with the `on` method
    def on_missing(&block)
      missing_events << block
      self
    end

    # Run the block whenever a step has completed regardless of outcome.
    def on_advance(&block)
      advance_events << block
      self
    end

    # Register a handler object to be used to handle events registered with #handler
    def register_handler_obj(obj)
      @handler_ctx = obj
    end

    # Register a method to call on the handler object when an event is triggered
    def handler(event, *meths)
      meths.each do |meth|
        events[event.to_sym] ||= []
        events[event.to_sym] << {type: :method, method: meth.to_sym}
      end
      self
    end
    alias handlers handler

    protected

    # Executes the event handlers(callable object or block) for each event and provides
    # a StepResult object to the handler.
    def fire_events(event_name, step_result)
      events_to_fire = events.fetch(event_name, missing_events)
      if events_to_fire.empty?
        fail EventMissingError, "No event registered for #{event_name}"
      end
      events_to_fire.each_with_index do |event, i|
        execute_event(event_name, event, step_result)
      end
      @last_event_fired = event_name
    end

    # This method will manually fire a single event,
    def fire(event, payload=nil)
      step_result = StepResult.new(true, "manual event")
      step_result.payload = payload if payload
      fire_events event, step_result
      step_result
    end

    # Override Step methods
    # In the context of events, invalid and stop are the same.
    # Fire the desired event and halt execution with a reason.
    # No payload is passed since no further steps will be called.
    def stop(event, reason="", bag={})
      step_errors << reason unless reason == ""
      r = StepResult.new(false, reason)
      r.bag = bag
      fire_events(event, r)
      r
    end

    # Fires the event and then passes a payload along to the next step
    def proceed(event=nil, bag={})
      r = StepResult.new(true)
      r.bag = bag
      fire_events(event, r) if event
      r
    end

    def halt(event)
      r = StepResult.new(false)
      fire_events(event, r)
      r
    end

    def invalid(event, message)
      step_errors << message unless message == ""
      r = StepResult.new(true, message)
      fire_events(event, r)
      r
    end

    def stop_with_exception(description, exception)
      r = StepResult.new(false, "Exception when #{description}", exception)
      fire_events(:exception, r)
      r
    end

    private

    def events
      @events ||= {}
    end

    def missing_events
      @missing_events ||= []
    end

    def advance_events
      @advance_events ||= []
    end

    def execute_event(event_name, event, step_result)
      if event[:type] == :block
        r = event[:block].call(step_result, event_name)
        advance_events.each do |advance_event|
          advance_event.call("ADVANCED: #{event_name}", r, step_result)
        end
        r
      elsif event[:type] == :method
        fail 'You must register a handler object with #register_handler_obj' unless @handler_ctx
        @handler_ctx.send(event[:method], step_result, event_name)
      else
        fail "Invalid event #{event_name} :: #{event}"
      end
    end

  end
end
