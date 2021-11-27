defmodule Crux.Interaction.MessageComponent.Button do
  @moduledoc """
  Buttons are interactive components.

  For buttons the following limitations apply:
  - Buttons must be in action rows.
  - There may be up to 5 buttons per action row.
  - All buttons require at least one of `label` and `emoji`.

  You may also want to checkout the [Discord Developer Documentation about buttons](https://discord.com/developers/docs/interactions/message-components#buttons).
  """
  @moduledoc since: "0.1.0"

  @custom_id_limit 100
  @label_limit 80

  defstruct [
    :style,
    :label,
    :emoji,
    :custom_id,
    :url,
    :disabled,
    type: 2
  ]

  @button_style_primary 1
  @button_style_secondary 2
  @button_style_success 3
  @button_style_danger 4
  @button_style_link 5

  @typedoc """
  Available button styles:
  - `primary` - 1
  - `secondary` - 2
  - `success` - 3
  - `danger` - 4
  - `link` - 5

  There is an image preview on the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/message-components#button-object-button-styles).
  """
  @typedoc since: "0.1.0"
  @type button_style :: 1..5

  @doc """
  The primary style, a blurple button.
  """
  @doc since: "0.1.0"
  @spec button_style_primary() :: button_style()
  def button_style_primary(), do: @button_style_primary

  @doc """
  The secondary style, a grey button.
  """
  @doc since: "0.1.0"
  @spec button_style_secondary() :: button_style()
  def button_style_secondary(), do: @button_style_secondary

  @doc """
  The success style, a green button.
  """
  @doc since: "0.1.0"
  @spec button_style_success() :: button_style()
  def button_style_success(), do: @button_style_success

  @doc """
  The danger style, a red button.
  """
  @doc since: "0.1.0"
  @spec button_style_danger() :: button_style()
  def button_style_danger(), do: @button_style_danger

  @doc """
  The links style, a grey button with a "link" icon to signify its purpose.
  """
  @doc since: "0.1.0"
  @spec button_style_link() :: button_style()
  def button_style_link(), do: @button_style_link

  @typedoc since: "0.1.0"
  @type t :: %__MODULE__{
          type: 2,
          style: button_style(),
          label: String.t() | nil,
          emoji:
            %{
              name: String.t() | nil,
              id: Crux.Structs.Snowflake.t() | nil,
              animated: boolean() | nil
            }
            | nil,
          custom_id: String.t() | nil,
          url: String.t() | nil,
          disabled: boolean() | nil
        }

  @doc """
  Create a new button using the given style and `custom_id` / `url`.

  See the `button_style___` functions in this module.
  There is a maximum of `#{@custom_id_limit}` characters for the `custom_id` (doesn't apply to the link style).
  """
  @doc since: "0.1.0"
  @spec new(link_style :: button_style(), url :: String.t()) :: t()
  def new(style, custom_id_or_url)

  def new(@button_style_link, url)
      when is_binary(url) do
    %__MODULE__{style: @button_style_link, url: url}
  end

  @spec new(non_link_style :: button_style(), custom_id :: String.t()) :: t()
  def new(style, custom_id)
      when is_binary(custom_id) do
    if String.length(custom_id) > @custom_id_limit do
      raise ArgumentError, "A button's custom_id may not be longer than 100 characters."
    else
      %__MODULE__{style: style, custom_id: custom_id}
    end
  end

  @doc """
  Set the emoji for a button.
  """
  @doc since: "0.1.0"
  @spec put_emoji(
          t(),
          emoji :: %{
            name: String.t() | nil,
            id: Crux.Structs.Snowflake.t() | nil,
            animated: boolean() | nil
          }
        ) :: t()
  def put_emoji(%__MODULE__{} = button, emoji) do
    %__MODULE__{button | emoji: emoji}
  end

  @doc """
  Set the label for a button.

  There is a maximum of `#{@label_limit}` characters.
  """
  @doc since: "0.1.0"
  @spec put_label(t(), String.t()) :: t()
  def put_label(%__MODULE__{} = button, label)
      when is_binary(label) do
    if String.length(label) > @label_limit do
      raise ArgumentError, "A button's label may not be longer than 80 characters."
    else
      %__MODULE__{button | label: label}
    end
  end

  @doc """
  Set whether a button is disabled. (I.e. can't be clicked)
  """
  @doc since: "0.1.0"
  @spec put_disabled(t(), boolean()) :: t()
  def put_disabled(%__MODULE__{} = button, disabled)
      when is_boolean(disabled) do
    %__MODULE__{button | disabled: disabled}
  end
end
