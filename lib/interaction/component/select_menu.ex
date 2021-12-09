defmodule Crux.Interaction.Component.SelectMenu do
  @moduledoc """
  Select menus are another interactive component that renders on messages.

  For select menus the following limitations apply:
  - Select menus must be in action rows.
  - There may be one select menu in an action row.

  You may also want to checkout the [Discord Developer Documentation about select menus](https://discord.com/developers/docs/interactions/message-components#select-menus).
  """
  @moduledoc since: "0.1.0"

  @custom_id_limit 100
  @placeholder_limit 100
  @options_limit 25

  alias __MODULE__.Option

  defstruct [
    :custom_id,
    :options,
    :placeholder,
    :min_values,
    :max_values,
    :disabled,
    type: 3
  ]

  @type t :: %__MODULE__{
          type: 3,
          custom_id: String.t(),
          options: Option.t(),
          placeholder: String.t() | nil,
          min_values: non_neg_integer() | nil,
          max_values: pos_integer() | nil,
          disabled: boolean() | nil
        }

  @doc """
  Create a new select menu with the given custom_id and option(s).

  There is a maximum of `#{@custom_id_limit}` characters for the custom id and a limit of `#{@options_limit}` options.
  """
  @doc since: "0.1.0"
  @spec new(custom_id :: String.t(), option_s :: Option.t() | [Option.t()]) :: t()
  def new(custom_id, option_s \\ [])

  def new(custom_id, %{} = option) do
    new(custom_id, [option])
  end

  def new(custom_id, options)
      when is_list(options) do
    cond do
      String.length(custom_id) > @custom_id_limit ->
        raise ArgumentError,
              "A select menu's custom_id may not be longer than #{@custom_id_limit} characters."

      Enum.count(options) > @options_limit ->
        raise ArgumentError, "A select menu may have up to #{@options_limit} options."

      true ->
        %__MODULE__{custom_id: custom_id, options: options}
    end
  end

  @doc """
  Add one or multiple options to the select menu.
  """
  @doc since: "0.1.0"
  @spec add_options(t(), Option.t()) :: t()
  def add_options(%__MODULE__{} = select_menu, %{} = option) do
    add_options(select_menu, [option])
  end

  @spec add_options(t(), [Option.t()]) :: t()
  def add_options(%__MODULE__{options: options} = select_menu, new_options)
      when is_list(options) do
    if Enum.count(options) + Enum.count(new_options) > @options_limit do
      raise ArgumentError, "A select menu may have up to #{@options_limit} options."
    else
      %__MODULE__{select_menu | options: options ++ new_options}
    end
  end

  @doc """
  Set a custom placeholder to be shown if nothing is selected.

  There is a maximum of `#{@placeholder_limit}` characters allowed.
  """
  @doc since: "0.1.0"
  @spec put_placeholder(t(), String.t()) :: t()
  def put_placeholder(%__MODULE__{} = select_menu, placeholder) do
    if String.length(placeholder) > @placeholder_limit do
      raise ArgumentError,
            "A select menu's placeholder may not be longer than #{@placeholder_limit} characters."
    else
      %__MODULE__{select_menu | placeholder: placeholder}
    end
  end

  @doc """
  Set the minimum number of items that must be chosen.
  """
  @doc since: "0.1.0"
  @spec put_min_values(t(), non_neg_integer()) :: t()
  def put_min_values(%__MODULE__{} = select_menu, min_values)
      when is_integer(min_values) and min_values >= 0 do
    %__MODULE__{select_menu | min_values: min_values}
  end

  @doc """
  Set the maximum number of items that may be chosen.
  """
  @doc since: "0.1.0"
  @spec put_max_values(t(), pos_integer()) :: t()
  def put_max_values(%__MODULE__{} = select_menu, max_values)
      when is_integer(max_values) and max_values >= 1 do
    %__MODULE__{select_menu | max_values: max_values}
  end

  @doc """
  Set whether the select menu is disabled.
  """
  @doc since: "0.1.0"
  @spec put_disabled(t(), boolean()) :: t()
  def put_disabled(%__MODULE__{} = select_menu, disabled)
      when is_boolean(disabled) do
    %__MODULE__{select_menu | disabled: disabled}
  end

  defmodule Option do
    @moduledoc """
    An option used in a select menu.

    You may also want to checkout the [Discord Developer Documentation about select menu options](https://discord.com/developers/docs/interactions/message-components#select-menu-object-select-option-structure).
    """
    @moduledoc since: "0.1.0"

    @label_limit 100
    @value_limit 100
    @description_limit 100

    defstruct [
      :label,
      :value,
      :description,
      :emoji,
      :default
    ]

    @typedoc since: "0.1.0"
    @type t :: %__MODULE__{
            label: String.t(),
            value: String.t(),
            description: String.t() | nil,
            emoji:
              %{
                name: String.t() | nil,
                id: Crux.Structs.Snowflake.t() | nil,
                animated: boolean() | nil
              }
              | nil,
            default: boolean() | nil
          }

    @doc """
    Create a new option using the given a `label` and `value`.

    There is a `#{@label_limit}` character limit for the `label` and a `#{@value_limit}` character limit for the `value`.
    """
    @doc since: "0.1.0"
    @spec new(label :: String.t(), value :: String.t()) :: t()
    def new(label, value) do
      cond do
        String.length(label) > @label_limit ->
          raise ArgumentError,
                "A select menu option label may not be longer than #{@label_limit} characters."

        String.length(value) > @value_limit ->
          raise ArgumentError,
                "A select menu option value may not be longer than #{@value_limit} characters."

        true ->
          %__MODULE__{label: label, value: value}
      end
    end

    @doc """
    Set the description shown below the option name.
    """
    @doc since: "0.1.0"
    @spec put_description(t(), String.t()) :: t()
    def put_description(%__MODULE__{} = option, description) do
      if String.length(description) > @description_limit do
        raise ArgumentError,
              "A select menu option description may not be longer than #{@description_limit} characters."
      else
        %__MODULE__{option | description: description}
      end
    end

    @doc """
    Set the emoji to display alongside the option name.
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
    def put_emoji(%__MODULE__{} = option, %{} = emoji) do
      %__MODULE__{option | emoji: emoji}
    end

    @doc """
    Set whether this option will be selected by default.
    """
    @doc since: "0.1.0"
    @spec put_default(t(), boolean()) :: t()
    def put_default(%__MODULE__{} = option, default)
        when is_boolean(default) do
      %__MODULE__{option | default: default}
    end
  end
end
