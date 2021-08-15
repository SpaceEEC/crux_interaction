defmodule MyBot.Ping do
  @moduledoc false
  use Crux.Interaction.ApplicationCommand.ChatInput

  @name "ping"
  @description "Pongs right back at you!"
end
