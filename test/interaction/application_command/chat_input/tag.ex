defmodule MyBot.Tag do
  @moduledoc false
  use Crux.Interaction.ApplicationCommand.ChatInput

  @name "tag"
  @description "Shows a tag."

  @required true
  @autocomplete true
  string("name", "The name of the tag")
end
