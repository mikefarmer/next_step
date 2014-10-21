class TestStepRunner
  include NextStep::StepRunner

  attr_accessor :stop_on

  def initialize(stop_on=nil)
    @stop_on = stop_on
  end

  def run_callables
    errors = []
    run_steps(callables, errors)
  end
  alias_method :run, :run_callables

  def run_symbols(symbol_list=nil)
    errors = []
    list = symbol_list || symbols
    run_steps(list, errors)
  end

  def callables
    [
      -> { test_one },
      -> { test_two },
      -> { test_three },
      -> { test_four }
    ]
  end

  def symbols
    [
      :test_one,
      :test_two,
      :test_three
    ]
  end

  def test_one
    if @stop_on == :one
      stop "stopped on one"
    else
      proceed
    end
  end

  def test_two
    if @stop_on == :two
      halt
    else
      proceed
    end
  end

  def test_three
    if @stop_on == :three
      invalid "stopped on three"
    else
      proceed
    end
  end

  def test_four
    safely :error do
      fail "stopped on four" if @stop_on == :four
    end
  end

end
