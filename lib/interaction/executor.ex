defmodule Crux.Interaction.Executor do
  @moduledoc """
  Behavior to provide commands and module to handle incoming interaction payloads to respond accordingly.

  ## Usage

  An example providing just registered commands:

  ```elixir
  defmodule MyApp.Executor do
    @behaviour Crux.Interaction.Executor

    @commands Crux.Interaction.Executor.map_commands([
      MyApp.Greet,
      MyApp.Info,
      MyApp.Ping,
      MyApp.Tag,
    ])

    @impl Crux.Interaction.Executor
    def get_commands() do
      @commands
    end

    # Optional callbacks here, as needed / wanted.
  end
  ```

  You could also not register any commands and just use the callbacks to handle interactions:

  ```elixir
  defmodule MyApp.Executor do
    @behaviour Crux.Interaction.Executor

    @impl Crux.Interaction.Executor
    def get_commands(), do: []

    @impl Crux.Interaction.Executor
    def handle_chat_input(interaction, context) do
      # Return some response
    end

    # Other optional callbacks here, as needed / wanted.
  end
  ```

  Or, of course, something in-between.

  ### Plug Usage

  You just need to plug your executor module into `Crux.Interaction.Plug`, see its moduledoc for a very small example.
  The plug will then take care of sending the response to Discord.

  ### Gateway Usage

  If you are using the gateway to receive interactions, you need to call `execute/3` yourself and also send the response back yourself too.

  That could look somewhat like this:
  ```elixir
  def handle_event(:INTERACTION_CREATE, interaction, _shard) do
    Crux.Interaction.Executor.execute(MyApp.Executor, interaction, %{some: :context}) # The context is optional and can be any term
    |> case do
      {:ok, response, _context} ->
        MyApp.Rest.create_interaction_response!(interaction.id, interaction.token, response)
      {:error, error_type, _context} ->
        # Do something with the error, see `t:error_type/0` for possible error types.
    end
  end

  ```

  """
  @moduledoc since: "0.1.0"

  @doc """
  Function returning all commands that the executor should work with.

  See also `map_commands/1` to map a list of `t:Crux.Interaction.ApplicationCommand.t/0` to the expected return value.
  """
  @doc since: "0.1.0"
  @callback get_commands() :: %{
              required({name :: String.t(), type :: pos_integer()}) =>
                commands :: Crux.Interaction.ApplicationCommand.t()
            }

  @typedoc """
  Possible return values for the `handle_` callbacks.

  See also: `reply/1`
  """
  @typedoc since: "0.1.0"
  @type handle_return() ::
          Crux.Rest.interaction_response()
          | {Crux.Rest.interaction_response(), new_context :: context()}
          | nil

  @doc """
  Function to handle all incoming component interactions.
  """
  @doc since: "0.1.0"
  @callback handle_component(
              interaction :: Crux.Interaction.interaction(),
              context :: context()
            ) :: handle_return()

  @doc """
  Function to handle all incoming modal interactions.
  """
  @doc since: "0.1.0"
  @callback handle_modal(
              interaction :: Crux.Interaction.interaction(),
              context :: context()
            ) :: handle_return()

  @doc """
  Fallback function to handle incoming chat input application command interaction for commands that are not registered
  or that didn't register a `c:Crux.Interaction.ApplicationCommand.handle/2` function.
  """
  @doc since: "0.1.0"
  @callback handle_chat_input(
              interaction :: Crux.Interaction.interaction(),
              context :: context()
            ) :: handle_return()

  @doc """
  Fallback function to handle incoming chat input application command interaction for commands that are not registered
  or that didn't register a `c:Crux.Interaction.ApplicationCommand.handle_autocomplete/2` function.
  """
  @doc since: "0.1.0"
  @callback handle_autocomplete(
              interaction :: Crux.Interaction.interaction(),
              context :: context()
            ) :: handle_return()

  @doc """
  Fallback to handle incoming interactions of unknown (sub-)types.
  """
  @doc since: "0.1.0"
  @callback handle_interaction(
              interaction :: Crux.Interaction.interaction(),
              context :: context()
            ) :: handle_return()

  @optional_callbacks [
    handle_component: 2,
    handle_modal: 2,
    handle_chat_input: 2,
    handle_autocomplete: 2,
    handle_interaction: 2
  ]

  @typedoc """
  A module implementing the `Crux.Interaction.Executor` behaivor.
  """
  @typedoc since: "0.1.0"
  @type t() :: module()

  @typedoc """
  A context to pass to `execute/3`, which will be forwarded and maybe updated in `handle_` callbacks.
  """
  @typedoc since: "0.1.0"
  @type context :: term()

  # interaction types
  @ping 1
  @application_command 2
  @message_component 3
  @autocomplete 4
  @modal 5

  # command types
  @chat_input 1
  @user 2
  @message 3

  @typedoc """
  Available error types:
  - `:unkown_type` - The interaction type or sub-type (e.g. application commands) is unknown
  - `:unhandled_type` - The executor does not register an appropriate handler for this type of interaction (i.e. component / modal)
  - `:unknown_command` - The executor does not know about the given command
  - `:unhandled_command` - The executor does know about the given command, but the command doesn't register a handler
  - `:no_return` - A responsible handler was called, but it returned `nil`.

  > New types might be added in the future
  """
  @typedoc since: "0.1.0"
  @type error_type() :: :unknown_type | :unknown_command | :unhandled_command

  @doc """
  Sends a response immediately.
  Useful / needed if the handler function needs more than 3 seconds to send a response or additional work after the initial reply is required.

  Returns `:error` if a response was already sent, otherwise `:ok`.

  Note that the handler function must return `nil` after using this method otherwise an error will be raised.
  """
  @doc since: "0.1.0"
  @spec reply(
          response ::
            Crux.Rest.interaction_response()
            | {Crux.Rest.interaction_response(), new_context :: context()}
        ) :: :ok | :error
  defdelegate reply(response), to: Crux.Interaction.Executor.Server

  @doc """
  Handles an incoming interaction dispatching it to the relevant `handle_` function either in this module or in one of the command modules.

  If no suitable function could be determine an error response will be returned.
  For ping interactions this function will just return a pong response.
  """
  @doc since: "0.1.0"
  @spec execute(
          executor :: t(),
          interaction :: Crux.Interaction.interaction(),
          context :: context()
        ) ::
          {:ok, Crux.Rest.interaction_response(), new_context :: context()}
          | {:error, error_type(), new_context :: context()}
  def execute(executor, interaction, context \\ %{})

  def execute(_executor, %{type: @ping}, context) do
    wrap_return(Crux.Interaction.Response.pong(), context)
  end

  def execute(
        executor,
        %{type: @application_command, data: %{type: subtype}} = interaction,
        context
      )
      when subtype not in [@chat_input, @message, @user] do
    call_optional_callback(executor, interaction, context, :handle_interaction, :unknown_type)
  end

  def execute(executor, %{type: type_} = interaction, context)
      when type_ in [@application_command, @autocomplete] do
    %{data: %{type: type, name: name}} = interaction

    executor.get_commands()
    |> Map.get({name, type})
    |> case do
      nil ->
        fun = if(type_ == @autocomplete, do: :handle_autocomplete, else: :handle_chat_input)
        call_optional_callback(executor, interaction, context, fun, :unknown_command)

      command ->
        fun = if(type_ == @autocomplete, do: :handle_autocomplete, else: :handle)

        call_handler(command, interaction, context, fun)
    end
  end

  def execute(executor, %{type: @message_component} = interaction, context) do
    call_optional_callback(executor, interaction, context, :handle_component, :unhandled_type)
  end

  def execute(executor, %{type: @modal} = interaction, context) do
    call_optional_callback(executor, interaction, context, :handle_modal, :unhandled_type)
  end

  # Fallback for unknown types
  def execute(executor, interaction, context) do
    call_optional_callback(executor, interaction, context, :handle_interaction, :unknown_type)
  end

  # If a `fun` is exported, call it, otherwise return an error tuple with the given `error`.
  defp call_optional_callback(executor, interaction, context, fun, error)
       when is_atom(executor) and is_atom(fun) and is_atom(error) do
    if function_exported?(executor, fun, 2) do
      call_handler(executor, interaction, context, fun)
    else
      {:error, error, context}
    end
  end

  defp call_handler(mod, interaction, context, fun) do
    Crux.Interaction.Executor.Server.start_child({mod, fun, [interaction, context]})
    |> case do
      {:ok, return} ->
        wrap_return(return, context)

      {:error, :no_reply} ->
        {:error, :no_return, context}
    end
  end

  # If no new context was returned from the handle_ function,
  # wrap it in a tuple with the old one for a consistent return value
  defp wrap_return({%{} = response, new_context}, _old_context) do
    {:ok, response, new_context}
  end

  defp wrap_return(%{} = response, old_context) do
    {:ok, response, old_context}
  end

  @doc """
  Maps a list of commands to a map expected by `c:get_commands/0`.

  You do not necessarily _need_ to use this function, but it helps mapping them into the correct format.
  """
  @doc since: "0.1.0"
  @spec map_commands([command :: Crux.Interaction.ApplicationCommand.t()]) :: %{
          required({name :: String.t(), type :: pos_integer()}) =>
            commands :: Crux.Interaction.ApplicationCommand.t()
        }
  def map_commands(commands) do
    commands
    |> Map.new(fn command ->
      data = command.__crux_command__()
      {{data.name, data.type}, command}
    end)
  end
end
