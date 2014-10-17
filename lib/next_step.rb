require "next_step/version"

module NextStep
  Event = Struct.new(:name, :message, :block) do
    def call(event_argument)
      block.call(event_argument)
    end
  end

  StepResult = Struct.new(:event, :reason, :payload)
  EventResult = Struct.new(:event, :reason, :payload)
  PipelineResult = Struct.new(:continue, :message, :payload)

  EventMissingError = Class.new(StandardError)

  autoload :StepRunner, 'next_step/step_runner'
  autoload :EventProcessor, 'next_step/event_processor'
  autoload :Pipeline, 'next_step/pipeline'
end
