class EventStepRunner
  include NextStep::StepRunner
  include NextStep::EventProcessor

  def initialize(stop_on=nil)
    @stop_on = stop_on
  end

  def run(steps=default_steps)
    errors = []
    run_steps(steps, errors)
  end

  def default_steps
    [
      :test_one,
      :test_two,
      :test_three
    ]
  end

  def test_one
    if @stop_on == :one
      stop :stopped, "stopped on one"
    else
      proceed :test_one
    end
  end

  def test_two
    if @stop_on == :two
      halt :halted
    else
      proceed :test_two
    end
  end

  def test_three
    if @stop_on == :three
      invalid :invalid, "stopped on three"
    else
      proceed :test_three
    end
  end

  def test_four
    safely :error do
      fail "stopped on four" if @stop_on == :four
    end
  end

end
