defmodule Crux.Interaction.Component.ActionRow do
  @moduledoc """
  An action row is a non-interactive container component for other types of components.

  The allowed components within an action row depends on where its used.

  For action rows the following limitations apply:
  - You can have at most `5` action rows within a message / interaction.
  - Action rows cannot contain action rows.
  - Action rows cannot mix components (as of yet).

  You may also want to checkout the [Discord Developer Documentation about action rows](https://discord.com/developers/docs/interactions/message-components#action-rows).
  """
  @moduledoc since: "0.1.0"

  alias Crux.Interaction.Component

  defstruct type: 1, components: []

  @typedoc since: "0.1.0"
  @type t :: %__MODULE__{
          type: 1,
          components: [Component.t()]
        }

  @doc """
  Create a new action row and optionally initialize it with the given component(s).
  """
  @doc since: "0.1.0"
  @spec new(Component.t() | [Component.t()]) :: t()
  def new(component_s \\ [])

  def new(%{} = component) do
    new([component])
  end

  def new(components) when is_list(components) do
    %__MODULE__{components: components}
  end

  @doc """
  Add one or multiple components to an action row.
  """
  @doc since: "0.1.0"
  @spec add_components(t(), Component.t()) :: t()
  def add_components(%__MODULE__{} = action_row, %{} = new_component) do
    add_components(action_row, [new_component])
  end

  @spec add_components(t(), [Component.t()]) :: t()
  def add_components(%__MODULE__{components: components} = action_row, new_components)
      when is_list(new_components) do
    %__MODULE__{action_row | components: components ++ new_components}
  end
end
