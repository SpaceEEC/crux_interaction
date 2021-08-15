defmodule MyBot.Greet do
  @moduledoc false
  use Crux.Interaction.ApplicationCommand.ChatInput

  @name "greet"
  @description "Greets a user"

  @required true
  string "type", "The type of the greeting" do
    choice("politely", "politely")
    choice("casually", "casually")
  end

  @required true
  user("user", "The user you'd like to greet")
end
