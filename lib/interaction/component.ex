defmodule Crux.Interaction.Component do
  @moduledoc """
  Components are interactive elements that may be added to messages or be sent as part of a response to an interaction.

  There are the following components:
  - `Crux.Interaction.Component.ActionRow`
  - `Crux.Interaction.Component.Button`
  - `Crux.Interaction.Component.InputText`
  - `Crux.Interaction.Component.SelectMenu`
  """

  @moduledoc since: "0.1.0"

  alias Crux.Interaction.Component.{
    ActionRow,
    Button,
    InputText,
    SelectMenu
  }

  @typedoc since: "0.1.0"
  @type t :: ActionRow.t() | Button.t() | InputText.t() | SelectMenu.t()
end
