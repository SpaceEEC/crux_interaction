defmodule Crux.Interaction.ExecutorTest do
  use ExUnit.Case, async: true

  alias Crux.Interaction.Executor

  doctest Executor

  defmodule MessageCommandExecutor do
    use Crux.Interaction.ApplicationCommand.Message

    @name "message"
  end

  defmodule UserCommandExecutor do
    use Crux.Interaction.ApplicationCommand.User

    @name "user"
  end

  test "map_commands/1" do
    commands =
      Executor.map_commands([
        MyBot.Ping,
        MyBot.Greet,
        MyBot.Info,
        MyBot.Tag,
        MessageCommandExecutor,
        UserCommandExecutor
      ])

    assert %{
             {"ping", 1} => MyBot.Ping,
             {"greet", 1} => MyBot.Greet,
             {"info", 1} => MyBot.Info,
             {"tag", 1} => MyBot.Tag,
             {"message", 3} => MessageCommandExecutor,
             {"user", 2} => UserCommandExecutor
           } == commands
  end

  describe "empty executor" do
    defmodule EmptyExecutor do
      @behaviour Executor

      @impl Executor
      def get_commands() do
        %{}
      end
    end

    test "ping" do
      interaction = %{
        id: "1234567890",
        application_id: "0987654321",
        type: 1,
        token: "token",
        version: 1
      }

      assert {:ok, response, _context} = Executor.execute(EmptyExecutor, interaction)

      assert %{type: 1} == response
    end

    test "component" do
      interaction = %{
        id: "1234567890",
        application_id: "0987654321",
        type: 3,
        data: %{
          custom_id: "100000000",
          component_type: 2
        },
        guild_id: "1357908642",
        channel_id: "2468097531",
        member: %{},
        user: %{},
        message: %{},
        token: "token",
        version: 1
      }

      assert {:error, :unhandled_type, _context} = Executor.execute(EmptyExecutor, interaction)
    end

    test "modal" do
      interaction = %{
        id: "1234567890",
        application_id: "0987654321",
        type: 5,
        data: %{
          custom_id: "100000000",
          components: [
            %{
              type: 1,
              components: [
                %{
                  type: 3,
                  custom_id: "input_1",
                  value: "interesting_name"
                }
              ]
            }
          ]
        },
        guild_id: "1357908642",
        channel_id: "2468097531",
        member: %{},
        user: %{},
        token: "token",
        version: 1
      }

      assert {:error, :unhandled_type, _context} = Executor.execute(EmptyExecutor, interaction)
    end

    test "unknown type" do
      interaction = %{
        id: "1234567890",
        application_id: "0987654321",
        type: -1,
        guild_id: "1357908642",
        channel_id: "2468097531",
        member: %{},
        user: %{},
        token: "token",
        version: 1
      }

      assert {:error, :unknown_type, _context} = Executor.execute(EmptyExecutor, interaction)
    end

    test "unknown sub type" do
      interaction = %{
        id: "1234567890",
        application_id: "0987654321",
        type: 2,
        data: %{
          type: -1
        },
        guild_id: "1357908642",
        channel_id: "2468097531",
        member: %{},
        user: %{},
        token: "token",
        version: 1
      }

      assert {:error, :unknown_type, _context} = Executor.execute(EmptyExecutor, interaction)
    end

    test "unhandled command" do
      interaction = %{
        id: "1234567890",
        application_id: "0987654321",
        type: 2,
        data: %{
          type: 1,
          name: "unhandled"
        },
        guild_id: "1357908642",
        channel_id: "2468097531",
        member: %{},
        user: %{},
        token: "token",
        version: 1
      }

      assert {:error, :unknown_command, _context} = Executor.execute(EmptyExecutor, interaction)
    end
  end

  describe "non-empty executor" do
    defmodule DummyChatInputCommand do
      use Crux.Interaction.ApplicationCommand.ChatInput

      @name "dummy"
      @description "dummy"

      import Crux.Interaction.Response

      def handle_autocomplete(_interaction, _context) do
        with_choices([%{name: "You", value: "me"}])
        |> autocomplete_result()
      end
    end

    defmodule ReplyChatInputCommand do
      use Crux.Interaction.ApplicationCommand.ChatInput

      @name "reply"
      @description "reply"

      import Crux.Interaction.Response

      def handle(_interaction, _context) do
        with_content(":wave:")
        |> channel_message()
        |> Executor.reply()

        nil
      end

      def handle_autocomplete(_interaction, _context) do
        nil
      end
    end

    defmodule DummyMessageCommand do
      use Crux.Interaction.ApplicationCommand.Message

      @name "dummy"

      import Crux.Interaction.Response

      def handle(_interaction, context) do
        response =
          with_content(":)")
          |> channel_message()

        {response, Map.put(context, :more, :context)}
      end
    end

    defmodule DummyExecutor do
      @behaviour Executor

      @commands Executor.map_commands([
                  ReplyChatInputCommand,
                  DummyMessageCommand,
                  DummyChatInputCommand
                ])

      @impl Executor
      def get_commands() do
        @commands
      end

      @impl Executor
      def handle_component(_interaction, _context) do
        import Crux.Interaction.Response

        with_content("This response will be sent to all component interactions received.")
        |> channel_message()
      end
    end

    test "handle/2 of the module is called" do
      interaction = %{
        id: "123",
        application_id: "456",
        type: 2,
        data: %{
          type: 3,
          name: "dummy"
        },
        member: %{},
        user: %{},
        token: "token",
        version: 1
      }

      {:ok, response, context} = Executor.execute(DummyExecutor, interaction)

      assert %{type: 4, data: %{content: ":)"}} == response
      assert %{more: :context} == context
    end

    test "autocomplete/2 of the module is called" do
      interaction = %{
        id: "123",
        application_id: "456",
        type: 4,
        data: %{
          type: 1,
          name: "dummy",
          options: [%{type: 3, name: "name", focused: true, value: "some name"}]
        },
        member: %{},
        user: %{},
        token: "token",
        version: 1
      }

      {:ok, response, _context} = Executor.execute(DummyExecutor, interaction)

      assert %{type: 8, data: %{choices: [%{name: "You", value: "me"}]}} == response
    end

    test "reply/1 works" do
      interaction = %{
        id: "123",
        application_id: "456",
        type: 2,
        data: %{
          type: 1,
          name: "reply"
        },
        member: %{},
        user: %{},
        token: "token",
        version: 1
      }

      {:ok, response, _context} = Executor.execute(DummyExecutor, interaction)

      assert %{type: 4, data: %{content: ":wave:"}} == response
    end

    test "optional callback works" do
      interaction = %{
        id: "1234567890",
        application_id: "0987654321",
        type: 3,
        data: %{
          custom_id: "665",
          component_type: 2
        },
        guild_id: "1357908642",
        channel_id: "2468097531",
        member: %{},
        user: %{},
        token: "token",
        version: 1
      }

      {:ok, response, _context} = Executor.execute(DummyExecutor, interaction)

      assert %{
               type: 4,
               data: %{
                 content: "This response will be sent to all component interactions received."
               }
             } == response
    end

    test "not returning returns an error" do
      interaction = %{
        id: "123",
        application_id: "456",
        type: 4,
        data: %{
          type: 1,
          name: "reply",
          options: [%{type: 3, name: "name", focused: true, value: "some name"}]
        },
        member: %{},
        user: %{},
        token: "token",
        version: 1
      }

      {:error, :no_return, _context} = Executor.execute(DummyExecutor, interaction)
    end
  end
end
