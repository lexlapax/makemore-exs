defmodule MakemoreTest do
  use ExUnit.Case
  doctest Makemore

  test "greets the world" do
    assert Makemore.hello() == :world
  end
end
