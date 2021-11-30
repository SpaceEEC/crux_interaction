defmodule Crux.Interaction.MessageComponent do
  @moduledoc """
  Message components are interactive elements that may be added to messages or be sent as part of a response to an interaction.

  There are the following message components:
  - `Crux.Interaction.MessageComponent.ActionRow`
  - `Crux.Interaction.MessageComponent.Button`
  - `Crux.Interaction.MessageComponent.InputText`
  - `Crux.Interaction.MessageComponent.SelectMenu`
  """

  @moduledoc since: "0.1.0"

  alias Crux.Interaction.MessageComponent.{
    ActionRow,
    Button,
    InputText,
    SelectMenu
  }

  @typedoc since: "0.1.0"
  @type t :: ActionRow.t() | Button.t() | InputText.t() | SelectMenu.t()
end
