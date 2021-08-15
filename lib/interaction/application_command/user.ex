defmodule Crux.Interaction.ApplicationCommand.User do
  @moduledoc since: "0.1.0"
  @moduledoc File.read!(Path.rootname(__ENV__.file) <> ".md")
  @external_resource Path.rootname(__ENV__.file) <> ".md"

  @user 2

  defmacro __using__([]) do
    quote do
      use Crux.Interaction.ApplicationCommand.ContextMenu, unquote(@user)
    end
  end
end
