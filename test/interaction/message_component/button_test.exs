defmodule Crux.Interaction.MessageComponent.ButtonTest do
  use ExUnit.Case, async: true
  alias Crux.Interaction.MessageComponent.Button
  doctest Button

  describe "button_style" do
    test "primary" do
      assert 1 === Button.button_style_primary()
    end

    test "secondary" do
      assert 2 === Button.button_style_secondary()
    end

    test "success" do
      assert 3 === Button.button_style_success()
    end

    test "danger" do
      assert 4 === Button.button_style_danger()
    end

    test "link" do
      assert 5 === Button.button_style_link()
    end
  end

  describe "new" do
    test "link" do
      assert %Button{type: 2, style: 5, url: "https://example.com"} =
               Button.new(Button.button_style_link(), "https://example.com")
    end

    test "valid custom_id" do
      assert %Button{type: 2, style: 1, custom_id: "primary"} =
               Button.new(Button.button_style_primary(), "primary")

      custom_id = String.duplicate("a", 100)

      assert %Button{type: 2, style: 1, custom_id: ^custom_id} =
               Button.new(Button.button_style_primary(), custom_id)
    end

    test "invalid custom_id raises" do
      assert_raise ArgumentError, ~r/custom_id/, fn ->
        Button.new(Button.button_style_primary(), String.duplicate("a", 101))
      end
    end
  end

  test "put_emoji/2" do
    assert %Button{type: 2, style: 2, custom_id: "custom_id", emoji: :some_emoji} =
             Button.new(Button.button_style_secondary(), "custom_id")
             |> Button.put_emoji(:some_emoji)
  end

  describe "put_label/2" do
    test "valid label" do
      assert %Button{type: 2, style: 3, custom_id: "custom_id", label: "hello there"} =
               Button.new(Button.button_style_success(), "custom_id")
               |> Button.put_label("hello there")

      label = String.duplicate("a", 80)

      assert %Button{type: 2, style: 3, custom_id: "custom_id", label: ^label} =
               Button.new(Button.button_style_success(), "custom_id")
               |> Button.put_label(label)
    end

    test "invalid label raises" do
      assert_raise ArgumentError, ~r/label/, fn ->
        Button.new(Button.button_style_primary(), "label")
        |> Button.put_label(String.duplicate("a", 81))
      end
    end
  end

  test "put_disabled/2" do
    assert %Button{type: 2, style: 4, custom_id: "custom_id", disabled: true} =
             Button.new(Button.button_style_danger(), "custom_id")
             |> Button.put_disabled(true)
  end
end
