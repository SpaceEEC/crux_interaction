defmodule Crux.Interaction.MessageComponent.SelectMenu.OptionTest do
  use ExUnit.Case, async: true
  alias Crux.Interaction.MessageComponent.SelectMenu.Option
  doctest Option

  describe "new/2" do
    test "valid values work" do
      assert %Option{label: "label", value: "value"} = Option.new("label", "value")
    end

    test "label and value limits are set" do
      label = String.duplicate("a", 100)
      value = String.duplicate("b", 100)

      assert %Option{label: ^label, value: ^value} = Option.new(label, value)
    end

    test "invalid label raises" do
      assert_raise ArgumentError, ~r/label/, fn ->
        Option.new(String.duplicate("a", 101), "value")
      end
    end

    test "invalid value raises" do
      assert_raise ArgumentError, ~r/value/, fn ->
        Option.new("label", String.duplicate("a", 101))
      end
    end
  end

  describe "put_description/2" do
    test "valid description works" do
      option = Option.new("label", "value")

      assert %Option{label: "label", value: "value", description: "description"} =
               option
               |> Option.put_description("description")
    end

    test "description limit works" do
      option = Option.new("label", "value")

      description = String.duplicate("a", 100)

      assert %Option{label: "label", value: "value", description: ^description} =
               option
               |> Option.put_description(description)
    end

    test "too long description raises" do
      option = Option.new("label", "value")

      assert_raise ArgumentError, ~r/description/, fn ->
        Option.put_description(option, String.duplicate("a", 101))
      end
    end
  end

  test "put_emoji/2" do
    assert %Option{label: "label", value: "value", emoji: %{some: :emoji}} =
             Option.new("label", "value")
             |> Option.put_emoji(%{some: :emoji})
  end

  describe "put_default/2" do
    test "booleans work" do
      assert %Option{label: "label", value: "value", default: true} =
               Option.new("label", "value")
               |> Option.put_default(true)

      assert %Option{label: "label", value: "value", default: false} =
               Option.new("label", "value")
               |> Option.put_default(false)
    end

    test "invalid value raises" do
      assert_raise FunctionClauseError, fn ->
        Option.new("label", "value")
        |> Option.put_default(%{})
      end
    end
  end
end
