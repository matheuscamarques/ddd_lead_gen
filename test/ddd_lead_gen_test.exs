defmodule DddLeadGenTest do
  use ExUnit.Case
  doctest DddLeadGen

  test "greets the world" do
    assert DddLeadGen.hello() == :world
  end
end
