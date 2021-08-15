defmodule MyBot.Info do
  @moduledoc false
  use Crux.Interaction.ApplicationCommand.ChatInput

  @name "info"
  @description "Shows basic info about a user, channel, or role."
  @default_permission true

  subcommand "user", "Show basic info about a user" do
    @required true
    user("user", "The user you want to show info about")
  end

  subcommand "channel", "Show basic info about a channel" do
    @required true
    channel("channel", "The channel you want to show basic info about")
  end

  subcommand "role", "Show basic info about a role" do
    @required true
    role("role", "The role you want to show basic info about")
  end
end
