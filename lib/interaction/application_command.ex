defmodule Crux.Interaction.ApplicationCommand do
  @moduledoc """
  Behavior providing `c:__crux_command__/0` to access underlying command data.

  Modules implementing this behavior:
  - `Crux.Interaction.ApplicationCommand.ChatInput`
  - `Crux.Interaction.ApplicationCommand.Message`
  - `Crux.Interaction.ApplicationCommand.User`
  """
  @moduledoc since: "0.1.0"

  @doc """
  A term representing the defined command, that when JSON encoded, is compatible with what the Discord API expects.

  > See the `Application Commands` section of `Crux.Rest` for usages.
  """
  @doc since: "0.1.0"
  @callback __crux_command__() :: Crux.Rest.application_command_data()
end
