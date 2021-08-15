Provides a DSL to define user application commands A.K.A. context menus.

Names may have spaces and can be up to 32 characters long.

It's recommend to checkout the [Discord Developer Documentation on User Commands](https://discord.com/developers/docs/interactions/application-commands#user-commands).

## Examples

```elixir
defmodule MyBot.BlockUser do
    use Crux.Interaction.ApplicationCommand.User

    @name "Block this User"
    # User commands can't have a @description
end
```