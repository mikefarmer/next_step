require "next_step/version"

module NextStep

  StepResult = Struct.new(:continue, :message, :exception, :payload, :step, :bag)
  EventMissingError = Class.new(StandardError)

  autoload :StepRunner, 'next_step/step_runner'
  autoload :EventProcessor, 'next_step/event_processor'
  autoload :Payload, 'next_step/payload'
  autoload :Matchers, 'next_step/matchers/next_step_matchers'
end
