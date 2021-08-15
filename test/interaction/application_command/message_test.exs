defmodule Crux.Interaction.MessageTest do
  use ExUnit.Case, async: true
  doctest Crux.Interaction.ApplicationCommand.Message

  alias Crux.Interaction.ApplicationCommand.Exceptions
  alias Crux.Interaction.ApplicationCommand.Message

  test "can't have @description" do
    assert_raise Exceptions.InvalidDescription, ~r/@description/, fn ->
      Code.eval_quoted(
        quote do
          defmodule MessageModule do
            use Message

            @name "test"
            @description "description"
          end
        end
      )
    end
  end

  describe "names" do
    test "upper case, spaces and special charas are okay" do
      {{:module, mod, _, _}, _binding} =
        Code.eval_quoted(
          quote do
            defmodule MessageModule2 do
              use Message

              @name "Viele Grüße"
            end
          end
        )

      assert %{name: "Viele Grüße", type: 3} === mod.__crux_command__()
    end

    test "invalid lenght throws" do
      assert_raise Exceptions.InvalidName, ~r/must be \[1,32\]/, fn ->
        Code.eval_quoted(
          quote do
            defmodule MessageModule3 do
              use Message

              @name ""
            end
          end
        )
      end
      assert_raise Exceptions.InvalidName, ~r/must be \[1,32\]/, fn ->
        Code.eval_quoted(
          quote do
            defmodule MessageModule4 do
              use Message

              @name String.duplicate("n", 33)
            end
          end
        )
      end
    end
  end
end
