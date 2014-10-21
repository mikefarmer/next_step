require 'next_step/matchers/run_step'
module NextStep::Matchers

  def run_step(step)
    RunStep.new(step)
  end

  def run_pipeline_step(step, payload)
    RunPipelineStep.new(step_payload)
  end

end
