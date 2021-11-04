Provides a DSL to define chat input application commands A.K.A. slash commands.

## Restrictions

Names must consist only of lowercase characters (and -) and may be up to 32 characters long.
Descriptions may be up to 100 characters long without further restrictions.

These name and description restrictions also apply to options.
For choices the name and descriptions both may be up to 100 characters long without further restrictions.

A chat input application command may have up to
- 25 subcommand groups
- 25 subcommand
- 25 options
- 25 choices
per grouping / level.

Maximum of 4000 characters for combined name, description, and value properties for each command and its subcommands and groups.


It's recommend to checkout the [Discord Developer Documentation on Chat Input Application Commands](https://discord.com/developers/docs/interactions/application-commands#slash-commands).


## Examples

A basic ping command:
```elixir
defmodule MyBot.Ping do
  use Crux.Interaction.ApplicationCommand.ChatInput

  @name "ping"
  @description "Pongs right back at you!"
end
```

A command using choices:
```elixir
defmodule MyBot.Greet do
  use Crux.Interaction.ApplicationCommand.ChatInput

  @name "greet"
  @description "Greets a user"

  @required true
  string "type", "The type of the greeting" do
    choice "politely", "politely"
    choice "casually", "casually"
  end

  @required true
  user "user", "The user you'd like to greet"
end
```

A command using sub commands.
Sub command groups can be used to nest one level further:
```elixir
defmodule MyBot.Info do
  use Crux.Interaction.ApplicationCommand.ChatInput
  
  @name "info"
  @description "Shows basic info about a user, channel, or role."
  # Only specific users / roles can use this command. (Needs to be separately specified per guild)
  @default_permission false

  subcommand "user", "Show basic info about a user" do
    @required true
    user "user", "The user you want to show info about"
  end

  subcommand "channel", "Show basic info about a channel" do
    @required true
    channel "channel", "The channel you want to show basic info about"
  end

  subcommand "role", "Show basic info about a role" do
    @required true
    role "role", "The role you want to show basic info about"
  end
end
```

A command using autocomplete to suggest the user options to chose from.
```elixir
defmodule MyBot.Tag do
  @moduledoc false
  use Crux.Interaction.ApplicationCommand.ChatInput

  @name "tag"
  @description "Shows a tag."

  @required true
  @autocomplete true
  string "name", "The name of the tag"
end
```