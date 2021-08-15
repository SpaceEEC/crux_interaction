defmodule Crux.Interaction.ApplicationCommand.ChatInputTest do
  use ExUnit.Case, async: true
  doctest Crux.Interaction.ApplicationCommand.ChatInput

  alias Crux.Interaction.ApplicationCommand.Exceptions
  alias Crux.Interaction.ApplicationCommand.ChatInput

  @compile {:no_warn_undefined, MyBot.Ping}
  @compile {:no_warn_undefined, MyBot.Greet}
  @compile {:no_warn_undefined, MyBot.Info}

  describe "the moduledoc examples work" do
    test "ping" do
      Code.compile_file("test/interaction/application_command/chat_input/ping.ex")

      data = MyBot.Ping.__crux_command__()

      assert %{
               name: "ping",
               description: "Pongs right back at you!",
               type: 1
             } === data
    end

    test "greet" do
      Code.compile_file("test/interaction/application_command/chat_input/greet.ex")

      data = MyBot.Greet.__crux_command__()

      assert %{
               name: "greet",
               description: "Greets a user",
               options: [
                 %{
                   type: 3,
                   required: true,
                   name: "type",
                   description: "The type of the greeting",
                   choices: [
                     %{
                       name: "politely",
                       value: "politely"
                     },
                     %{
                       name: "casually",
                       value: "casually"
                     }
                   ]
                 },
                 %{
                   type: 6,
                   required: true,
                   name: "user",
                   description: "The user you'd like to greet"
                 }
               ],
               type: 1
             } === data
    end

    test "info" do
      Code.compile_file("test/interaction/application_command/chat_input/info.ex")

      data = MyBot.Info.__crux_command__()

      assert %{
               name: "info",
               description: "Shows basic info about a user, channel, or role.",
               default_permission: true,
               options: [
                 %{
                   type: 1,
                   name: "user",
                   description: "Show basic info about a user",
                   options: [
                     %{
                       type: 6,
                       required: true,
                       name: "user",
                       description: "The user you want to show info about"
                     }
                   ]
                 },
                 %{
                   type: 1,
                   name: "channel",
                   description: "Show basic info about a channel",
                   options: [
                     %{
                       type: 7,
                       required: true,
                       name: "channel",
                       description: "The channel you want to show basic info about"
                     }
                   ]
                 },
                 %{
                   type: 1,
                   name: "role",
                   description: "Show basic info about a role",
                   options: [
                     %{
                       type: 8,
                       required: true,
                       name: "role",
                       description: "The role you want to show basic info about"
                     }
                   ]
                 }
               ],
               type: 1
             } === data
    end
  end

  describe "invalid name / description / value throw" do
    test "invalid command name" do
      assert_raise Exceptions.InvalidName, ~r/chat input name/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "Name"
              @description "description"
            end
          end
        )
      end
    end

    test "invalid command description" do
      assert_raise Exceptions.InvalidDescription, ~r/chat input description/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "name"
              @description String.duplicate("d", 101)
            end
          end
        )
      end
    end

    test "invalid option name" do
      assert_raise Exceptions.InvalidName, ~r/chat input option name/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "name"
              @description "description"

              string("Foo", "bar")
            end
          end
        )
      end
    end

    test "duplicated option name" do
      assert_raise Exceptions.InvalidName, ~r/duplicated option names/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "name"
              @description "description"

              string("foo", "foo")
              string("foo", "bar")
            end
          end
        )
      end
    end

    test "invalid option description" do
      assert_raise Exceptions.InvalidDescription, ~r/chat input option description/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "name"
              @description "description"

              string("foo", String.duplicate("d", 101))
            end
          end
        )
      end
    end

    test "invalid choice name" do
      assert_raise Exceptions.InvalidName, ~r/option choice name/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "name"
              @description "description"

              string "foo", "bar" do
                choice(String.duplicate("d", 101), "bar")
              end
            end
          end
        )
      end
    end

    test "duplicate choice name" do
      assert_raise Exceptions.InvalidName, ~r/duplicated choice names/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "name"
              @description "description"

              string "foo", "foo" do
                choice("bar", "bar")
                choice("bar", "baz")
              end
            end
          end
        )
      end
    end

    test "invalid choice string value" do
      assert_raise Exceptions.InvalidChoice, ~r/option choice value/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "name"
              @description "description"

              string "foo", "bar" do
                choice("bar", String.duplicate("d", 101))
              end
            end
          end
        )
      end
    end

    test "invalid choice integer value" do
      assert_raise Exceptions.InvalidChoice, ~r/must be an integer/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "name"
              @description "description"

              integer "foo", "bar" do
                choice("bar", -9_007_199_254_740_993)
              end
            end
          end
        )
      end

      assert_raise Exceptions.InvalidChoice, ~r/must be an integer/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "name"
              @description "description"

              integer "foo", "bar" do
                choice("bar", 1.5)
              end
            end
          end
        )
      end
    end

    test "invalid choice number value" do
      assert_raise Exceptions.InvalidChoice, ~r/must be a double/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "name"
              @description "description"

              number "foo", "bar" do
                choice("bar", -9_007_199_254_740_993)
              end
            end
          end
        )
      end
    end
  end

  test "invalid default permission" do
    assert_raise Exceptions.InvalidDefaultPermission, ~r/must be a boolean/, fn ->
      Code.eval_quoted(
        quote do
          defmodule TestModule do
            use ChatInput

            @name "name"
            @description "description"
            @default_permission %{}
          end
        end
      )
    end
  end

  describe "invalid @required throw" do
    test "choices can't be @required" do
      assert_raise Exceptions.InvalidState, ~r/@required is only valid for options/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "name"
              @description "description"

              string "foo", "bar" do
                @required true
                choice("bar", "bar")
              end
            end
          end
        )
      end
    end

    test "subcommands can't be @required" do
      assert_raise Exceptions.InvalidState, ~r/@required is only valid for options/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "name"
              @description "description"

              @required true
              subcommand("foo", "bar")
            end
          end
        )
      end
    end

    test "required after optional throws" do
      assert_raise Exceptions.InvalidState, ~r/required after optional/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "name"
              @description "description"

              string("foo", "foo")

              @required true
              string("bar", "bar")
            end
          end
        )
      end
    end

    test "required with non-boolean throws" do
      assert_raise ArgumentError, ~r/must be a boolean/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "test"
              @description "description"

              @required %{}
              string("foo", "foo")
            end
          end
        )
      end
    end
  end

  describe "invalid states" do
    test "can't mix types" do
      assert_raise Exceptions.InvalidState, ~r/Can't mix different states/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "name"
              @description "description"

              integer("foo", "bar")

              subcommand_group "baz", "baz" do
              end
            end
          end
        )
      end
    end

    test "require valid transition" do
      assert_raise Exceptions.InvalidState, ~r/Expected one of the .+ states/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "name"
              @description "description"

              choice("foo", "bar")
            end
          end
        )
      end

      assert_raise Exceptions.InvalidState, ~r/Expected one of the .+ states/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "name"
              @description "description"

              subcommand_group "baz", "baz" do
                choice("foo", "bar")
              end
            end
          end
        )
      end

      assert_raise Exceptions.InvalidState, ~r/Expected one of the .+ states/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "name"
              @description "description"

              string "baz", "baz" do
                subcommand("foo", "bar")
              end
            end
          end
        )
      end
    end
  end

  describe "scope/choice limits" do
    test "scope limit throws" do
      assert_raise Exceptions.InvalidState, ~r/limited to 25/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "name"
              @description "description"

              for i <- 0..25 do
                string(to_string(i), "foo")
              end
            end
          end
        )
      end
    end

    test "choie limit throws" do
      assert_raise Exceptions.InvalidState, ~r/limited to 25/, fn ->
        Code.eval_quoted(
          quote do
            defmodule TestModule do
              use ChatInput

              @name "name"
              @description "description"

              string "foo", "foo" do
                for i <- 0..25 do
                  choice(to_string(i), "foo")
                end
              end
            end
          end
        )
      end
    end
  end

  test "various options" do
    {{:module, mod, _, _}, _binding} =
      Code.eval_quoted(
        quote do
          defmodule VariousOptionsModule do
            use ChatInput

            @name "test"
            @description "module"

            number("foo", "foo")
            mentionable("bar", "bar")
            boolean("baz", "baz")
          end
        end
      )

    assert %{
             name: "test",
             description: "module",
             type: 1,
             options: [
               %{
                 type: 10,
                 name: "foo",
                 description: "foo"
               },
               %{
                 type: 9,
                 name: "bar",
                 description: "bar"
               },
               %{
                 type: 5,
                 name: "baz",
                 description: "baz"
               }
             ]
           } === mod.__crux_command__()
  end

  describe "non-english command names work" do
    test "grüße" do
      {{:module, mod, _, _}, _binding} =
        Code.eval_quoted(
          quote do
            defmodule GruesseModule do
              use ChatInput

              @name "grüße"
              @description "description"
            end
          end
        )

      assert "grüße" === mod.__crux_command__().name
    end

    test "どうも" do
      {{:module, mod, _, _}, _binding} =
        Code.eval_quoted(
          quote do
            defmodule DoumoModule do
              use ChatInput

              @name "どうも"
              @description "description"
            end
          end
        )

      assert "どうも" === mod.__crux_command__().name
    end
  end
end
