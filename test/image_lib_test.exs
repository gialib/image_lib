defmodule ImageLibTest do
  use ExUnit.Case
  doctest ImageLib

  test "the truth" do
    assert 1 + 1 == 2
  end

  test ".log_debug" do
    ImageLib.log_debug("ImageLib.log_debug()")
  end
end
