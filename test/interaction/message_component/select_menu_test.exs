defmodule Crux.Interaction.Component.SelectMenuTest do
  use ExUnit.Case, async: true
  alias Crux.Interaction.Component.SelectMenu
  doctest SelectMenu

  describe "new" do
    test "/1 valid id works" do
      assert %SelectMenu{type: 3, custom_id: "custom_id", options: []} =
               SelectMenu.new("custom_id")
    end

    test "/1 invalid id raises" do
      assert_raise ArgumentError, ~r/custom_id/, fn ->
        SelectMenu.new(String.duplicate("a", 101))
      end
    end

    test "/2" do
      assert %SelectMenu{type: 3, custom_id: "custom_id", options: [%{some: :option}]} =
               SelectMenu.new("custom_id", %{some: :option})

      assert %SelectMenu{
               type: 3,
               custom_id: "custom_id",
               options: [%{some: :option}, %{another: :option}]
             } = SelectMenu.new("custom_id", [%{some: :option}, %{another: :option}])
    end

    test "/2 too many options throw" do
      assert_raise ArgumentError, ~r/options/, fn ->
        SelectMenu.new("custom_id", List.duplicate(%{some: :option}, 26))
      end
    end
  end

  describe "add_options/2" do
    test "single entry" do
      select_menu = SelectMenu.new("custom_id", %{some: :option})

      assert %SelectMenu{
               type: 3,
               custom_id: "custom_id",
               options: [
                 %{some: :option},
                 %{another: :option}
               ]
             } =
               select_menu
               |> SelectMenu.add_options(%{another: :option})
    end

    test "list of entries" do
      select_menu = SelectMenu.new("custom_id", %{some: :option})

      assert %SelectMenu{
               type: 3,
               custom_id: "custom_id",
               options: [
                 %{some: :option},
                 %{another: :option},
                 %{more: :options}
               ]
             } =
               select_menu
               |> SelectMenu.add_options([%{another: :option}, %{more: :options}])
    end

    test "too many entries raise" do
      select_menu = SelectMenu.new("custom_id", %{some: :option})

      assert_raise ArgumentError, ~r/options/, fn ->
        SelectMenu.add_options(select_menu, List.duplicate(%{more: :options}, 25))
      end
    end
  end

  describe "put_placeholder/2" do
    test "valid placeholder works" do
      select_menu = SelectMenu.new("custom_id")

      assert %SelectMenu{
               type: 3,
               custom_id: "custom_id",
               options: [],
               placeholder: "Hold my place!"
             } = SelectMenu.put_placeholder(select_menu, "Hold my place!")
    end

    test "invalid placeholder raises" do
      select_menu = SelectMenu.new("custom_id")

      assert_raise ArgumentError, ~r/placeholder/, fn ->
        SelectMenu.put_placeholder(select_menu, String.duplicate("a", 101))
      end
    end
  end

  describe "put_min_values/2" do
    test "valid number works" do
      select_menu = SelectMenu.new("custom_id")

      %SelectMenu{type: 3, custom_id: "custom_id", options: [], min_values: 0} =
        select_menu
        |> SelectMenu.put_min_values(0)
    end

    test "invalid numbers raise" do
      select_menu = SelectMenu.new("custom_id")

      assert_raise FunctionClauseError, fn ->
        SelectMenu.put_min_values(select_menu, -1)
      end
    end
  end

  describe "put_max_values/2" do
    test "valid number works" do
      select_menu = SelectMenu.new("custom_id")

      %SelectMenu{type: 3, custom_id: "custom_id", options: [], max_values: 1} =
        select_menu
        |> SelectMenu.put_max_values(1)
    end

    test "invalid numbers raise" do
      select_menu = SelectMenu.new("custom_id")

      assert_raise FunctionClauseError, fn ->
        select_menu
        |> SelectMenu.put_max_values(0)
      end
    end
  end

  describe "put_disabled/2" do
    test "valid boolean works" do
      select_menu = SelectMenu.new("custom_id")

      %SelectMenu{type: 3, custom_id: "custom_id", options: [], disabled: true} =
        SelectMenu.put_disabled(select_menu, true)

      %SelectMenu{type: 3, custom_id: "custom_id", options: [], disabled: false} =
        SelectMenu.put_disabled(select_menu, false)
    end

    test "invalid value raises" do
      select_menu = SelectMenu.new("custom_id")

      assert_raise FunctionClauseError, fn ->
        SelectMenu.put_disabled(select_menu, %{})
      end
    end
  end
end
