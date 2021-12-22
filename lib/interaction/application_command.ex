defmodule Crux.Interaction.ApplicationCommand do
  @moduledoc """
  Behavior providing `c:__crux_command__/0` to access underlying command data.

  Modules implementing this behavior:
  - `Crux.Interaction.ApplicationCommand.ChatInput`
  - `Crux.Interaction.ApplicationCommand.Message`
  - `Crux.Interaction.ApplicationCommand.User`
  """
  @moduledoc since: "0.1.0"

  @typedoc """
  All modules that `use` one of the in the moduledoc mentioned modules.
  """
  @typedoc since: "0.1.0"
  @type t() :: module()

  @doc """
  Handle and respond to interactions.
  """
  @doc since: "0.1.0"
  @callback handle(
              interaction :: Crux.Interaction.interaction(),
              context :: Crux.Interaction.Executor.context()
            ) :: Crux.Interaction.Executor.handle_return()

  @doc """
  Handle autocomplete interactions.

  Only applicable if the defined interaction supports and registers such.
  """
  @doc since: "0.1.0"
  @callback handle_autocomplete(
              interaction :: Crux.Interaction.interaction(),
              context :: Crux.Interaction.Executor.context()
            ) :: Crux.Interaction.Executor.handle_return()

  @doc """
  A term representing the defined command, that when JSON encoded, is compatible with what the Discord API expects.

  > See the `Application Commands` section of `Crux.Rest` for usages.
  """
  @doc since: "0.1.0"
  @callback __crux_command__() :: Crux.Rest.application_command_data()

  @optional_callbacks [handle: 2, handle_autocomplete: 2]
end
