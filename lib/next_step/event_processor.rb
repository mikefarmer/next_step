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

    def on(event, &block)
      events[event.to_sym] ||= []
      events[event.to_sym] << Event.new(event.to_sym, "", block)
      self
    end

    # Run the block when an event is raised that is not being captured with the `on` method
    def on_missing(&block)
      missing_events << Event.new(:_missing, "", block)
      self
    end


    # Run the block whenever a step has completed regardless of outcome.
    def on_advance(&block)
      advance_events << Event.new(:_advanced, "", block)
      self
    end

    protected

    # Executes the event handlers(callable object or block) for each event and provides
    # an EventResult object to the handler. An event result is just 
    # the payload along with a reason for calling the event.
    def fire_events(event_name, event_result)
      return if event_name == :none
      events_to_fire = events.fetch(event_name, missing_events)
      events_to_fire = (events_to_fire | advance_events)
      if events_to_fire.empty?
        fail EventMissingError.new("No event registered for #{event_name}")
      end
      events_to_fire.each do |event| 
        event.call(event_result)
      end
      @last_event_fired = event_name
      
    end

    # Override the execute step from StepRunner to allow
    # passing payloads from one step to another.
    def execute_step(step, payload=nil)
      @steps_accept_payload = true unless defined?(@steps_accept_payload)
      if @steps_accept_payload
        step.call(payload)
      else 
        step.call
      end
    end

    # This method will manually fire a single event,
    def fire(event, payload=nil)
      proceed(event, payload)
    end

    # Override Step methods 
    # In the context of events, invalid and stop are the same.
    # Fire the desired event and halt execution with a reason.
    # No payload is passed since no further steps will be called.
    def stop(event, reason="")
      fire_events(event, EventResult.new(event, reason, nil))
      false
    end
    alias_method :invalid, :stop


    # Fires the event and then passes a payload along to the next step
    def proceed(event=:none, payload=nil)
      fire_events(event, EventResult.new(event, nil, payload))
      true
    end

    def safely(event, error=nil)
      yield if block_given?
      proceed
    rescue => e
      message = error ? error : e.message
      stop event, message
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

  end
end
