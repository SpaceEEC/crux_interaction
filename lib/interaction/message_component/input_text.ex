defmodule Crux.Interaction.MessageComponent.InputText do
  @moduledoc """
  # THIS IS NOT RELEASED / AVAILABLE YET.
  # EVERYTHING IS SUBJECT TO CHANGE.

  For input text the following limitations apply:
  - Input text may only be used in an interaction response. (Not in regular messages)
  - Input text must be in action rows.
  - There may only be one input text per action row.

  You may also want to checkout the Discord Developer Documentation about input text. (Does not exist yet)
  """
  @moduledoc since: "0.1.0"

  defstruct [
    :style,
    :custom_id,
    :label,
    :placeholder,
    :min_length,
    :max_length,
    type: 4
  ]

  @text_style_short 1
  @text_style_paragraph 2

  @typedoc """
  Availabel text styles:
  - `short` - 1
  - `paragraph` - 2
  """
  @typedoc since: "0.1.0"
  @type text_style :: 1..2

  @doc """
  The short text style, a single row for text.
  """
  @doc since: "0.1.0"
  def text_style_short(), do: @text_style_short

  @doc """
  The paragraph text syle, a multi line text box.
  """
  @doc since: "0.1.0"
  def text_style_paragraph(), do: @text_style_paragraph

  @typedoc since: "0.1.0"
  @type t :: %__MODULE__{
          type: 4,
          style: text_style(),
          custom_id: String.t(),
          label: String.t(),
          placeholder: String.t() | nil,
          min_length: non_neg_integer() | nil,
          max_length: pos_integer() | nil
        }

  @doc """
  Create an input text with the given `custom_id` and `label`.
  """
  @doc since: "0.1.0"
  @spec new(text_style(), custom_id :: String.t(), label :: String.t()) :: t()
  def new(text_style, custom_id, label) do
    # No documented custom_id / label limits yet
    %__MODULE__{style: text_style, custom_id: custom_id, label: label}
  end

  @doc """
  Set the placeholder text to show if no text was provided (yet).
  """
  @doc since: "0.1.0"
  @spec put_placeholder(t(), String.t()) :: t()
  def put_placeholder(%__MODULE__{} = input_text, placeholder) do
    # No documented placeholder limit yet
    %__MODULE__{input_text | placeholder: placeholder}
  end

  @doc """
  Set the minimum length required for the text.
  """
  @doc since: "0.1.0"
  @spec put_min_length(t(), non_neg_integer()) :: t()
  def put_min_length(%__MODULE__{} = input_text, min_length)
      when is_integer(min_length) and min_length >= 0 do
    %__MODULE__{input_text | min_length: min_length}
  end

  @doc """
  Set the maximum length required for the text.
  """
  @doc since: "0.1.0"
  @spec put_max_length(t(), pos_integer()) :: t()
  def put_max_length(%__MODULE__{} = input_text, max_length)
      when is_integer(max_length) and max_length >= 1 do
    %__MODULE__{input_text | max_length: max_length}
  end
end
