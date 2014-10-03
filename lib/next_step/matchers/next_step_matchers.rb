require 'next_step/matchers/run_step'
module NextStep::Matchers

  def run_step(step)
    RunStep.new(step)
  end

end
