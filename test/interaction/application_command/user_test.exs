defmodule Crux.Interaction.UserTest do
  use ExUnit.Case, async: true
  doctest Crux.Interaction.ApplicationCommand.User

  alias Crux.Interaction.ApplicationCommand.Exceptions
  alias Crux.Interaction.ApplicationCommand.User

  test "can't have @description" do
    assert_raise Exceptions.InvalidDescription, ~r/@description/, fn ->
      Code.eval_quoted(
        quote do
          defmodule UserModule do
            use User

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
            defmodule UserModule2 do
              use User

              @name "Viele Grüße"
            end
          end
        )

      assert %{name: "Viele Grüße", type: 2} === mod.__crux_command__()
    end

    test "invalid lenght throws" do
      assert_raise Exceptions.InvalidName, ~r/must be \[1,32\]/, fn ->
        Code.eval_quoted(
          quote do
            defmodule UserModule3 do
              use User

              @name ""
            end
          end
        )
      end

      assert_raise Exceptions.InvalidName, ~r/must be \[1,32\]/, fn ->
        Code.eval_quoted(
          quote do
            defmodule UserModule4 do
              use User

              @name String.duplicate("n", 33)
            end
          end
        )
      end
    end
  end
end
