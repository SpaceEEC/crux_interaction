defmodule Crux.Interaction.ApplicationCommand.Message do
  @moduledoc since: "0.1.0"
  @moduledoc File.read!(Path.rootname(__ENV__.file) <> ".md")
  @external_resource Path.rootname(__ENV__.file) <> ".md"

  @message 3

  defmacro __using__([]) do
    quote do
      use Crux.Interaction.ApplicationCommand.ContextMenu, unquote(@message)
    end
  end
end
