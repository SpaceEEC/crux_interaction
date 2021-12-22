defmodule Crux.Interaction do
  @moduledoc false
  @moduledoc since: "0.1.0"

  @doc """
  You can configure the json library to use:
  ```elixir
  config :crux_interaction, :json_library, Jason
  ```
  """
  @doc since: "0.1.0"
  @spec json_library() :: module()
  def json_library() do
    Application.get_env(:crux_interaction, :json_library, Jason)
  end

  @typedoc """
  An interaction received from Discord.

  For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object).
  """
  @typedoc since: "0.1.0"
  @type interaction :: map()
end
