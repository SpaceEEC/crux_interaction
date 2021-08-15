Provides a DSL to define message application commands A.K.A. context menus.

Names may have spaces and can be up to 32 characters long.

It's recommend to checkout the [Discord Developer Documentation on Message Commands](https://discord.com/developers/docs/interactions/application-commands#message-commands).


## Examples

```elixir
defmodule MyBot.StarMessage do
    use Crux.Interaction.ApplicationCommand.Message

    @name "Star this Message"
    # Message commands can't have a @description
end
```