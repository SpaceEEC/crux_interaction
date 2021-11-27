defmodule Crux.Interaction.MessageComponent.ActionRowTest do
  use ExUnit.Case, async: true
  alias Crux.Interaction.MessageComponent.ActionRow
  doctest ActionRow

  describe "new" do
    test "/0" do
      assert %ActionRow{type: 1, components: []} = ActionRow.new()
    end

    test "/1" do
      assert %ActionRow{type: 1, components: []} = ActionRow.new([])

      assert %ActionRow{type: 1, components: [%ActionRow{type: 1, components: []}]} =
               ActionRow.new(ActionRow.new())

      assert %ActionRow{
               type: 1,
               components: [
                 %ActionRow{type: 1, components: []},
                 %ActionRow{type: 1, components: []}
               ]
             } = ActionRow.new([ActionRow.new(), ActionRow.new()])
    end
  end

  describe "add_components/1" do
    test "single component" do
      action_row = ActionRow.new([])

      assert %ActionRow{type: 1, components: [%ActionRow{type: 1, components: []}]} =
               ActionRow.add_components(action_row, ActionRow.new())
    end

    test "list of components" do
      action_row = ActionRow.new([])

      assert %ActionRow{
               type: 1,
               components: [
                 %ActionRow{type: 1, components: []},
                 %ActionRow{type: 1, components: []}
               ]
             } = ActionRow.add_components(action_row, [ActionRow.new(), ActionRow.new()])
    end

    test "appends to the end of the list" do
      assert %ActionRow{
               type: 1,
               components: [
                 %ActionRow{type: 2, components: []},
                 %ActionRow{type: 4, components: []}
               ]
             } =
               ActionRow.new([])
               |> ActionRow.add_components(%ActionRow{type: 2, components: []})
               |> ActionRow.add_components(%ActionRow{type: 4, components: []})
    end
  end
end
