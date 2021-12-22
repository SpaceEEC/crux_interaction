# Crux.Interaction [![](https://github.com/SpaceEEC/crux_interaction/workflows/Tests/badge.svg?event=push&branch=trunk)](https://github.com/SpaceEEC/crux_interaction/actions) [![](https://github.com/SpaceEEC/crux_interaction/workflows/Documentation/badge.svg?event=push&branch=trunk)](https://spaceeec.github.io/crux_interaction)

Library providing DSLs to define [application commands](https://discord.com/developers/docs/interactions/application-commands) for Discord applications / bots, as well as ways to handle incoming interactions (either through webhook [read: `plug`s] or gateway [read: probably `crux_gateway`]) and respond to them.

## Useful links
- Documentation TBD
- [GitHub](https://github.com/SpaceEEC/crux_interaction)
- Changelog TBD
- [Trunk Documentation](https://spaceeec.github.io/crux_interaction/)

## Installation

For now `crux_interaction` can be installbed by adding it as a git dependencies to your `mix.exs`:

```elixir
def deps do
  [
    {:crux_interaction, github: "SpaceEEC/crux_interaction"}
  ]
end
```

## Configuration

You can configure the json library `crux_interaction` use:
```elixir
config :crux_interaction, :json_library, Jason # That's the default value
```

## Usage

Refer to the moduledocs for examples and API reference.
See useful links above for the documentation.

