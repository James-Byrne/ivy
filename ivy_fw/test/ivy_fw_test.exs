defmodule IvyFwTest do
  use ExUnit.Case
  doctest IvyFw

  test "greets the world" do
    assert IvyFw.hello() == :world
  end
end
