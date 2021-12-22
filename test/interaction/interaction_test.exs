defmodule Crux.InteractionTest do
  use ExUnit.Case, async: true
  doctest Crux.Interaction

  test "default json library is jason" do
    assert Jason == Crux.Interaction.json_library()
  end
end
