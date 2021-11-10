defmodule Crux.Interaction.ApplicationCommand.Exceptions do
  @moduledoc false

  defmodule InvalidDescription do
    @moduledoc since: "0.1.0"
    @moduledoc """
    Raised when an invalid description was specified anywhere.
    See: `valid?/1`
    """
    defexception [:message]

    @impl true
    def exception(:context_menu) do
      message = """
      Context menus may not have a @description set.\
      """

      %__MODULE__{message: message}
    end

    def exception({:option, description}) do
      message = """
      Invalid application command chat input option description, must be [1,100] characters long.
      Got: #{inspect(description)}\
      """

      %__MODULE__{message: message}
    end

    def exception(description) do
      message = """
      Invalid application command chat input description, must be [1,100] characters long.
      Got: #{inspect(description)}\
      """

      %__MODULE__{message: message}
    end

    @doc """
    Whether the given description is valid for a chat input or a chat input option.
    A description is valid, if it's [1,100] characters long.
    """
    @doc since: "0.1.0"
    @spec valid?(String.t()) :: boolean()
    def valid?(description) do
      with true <- String.valid?(description) do
        length = String.length(description)
        length > 0 and length <= 100
      end
    end
  end

  defmodule InvalidName do
    @moduledoc since: "0.1.0"
    @moduledoc """
    Raised when an invalid name was specified anywhere.
    See: `valid?/1`
    """
    defexception [:message]
    @chat_input 1
    @user 2
    @message 3

    @impl true
    def exception({:duplicate, :option, name}) do
      message = """
      Can't have duplicated option names: #{inspect(name)}\
      """

      %__MODULE__{message: message}
    end

    def exception({:duplicate, :choice, name}) do
      message = """
      Can't have duplicated choice names: #{inspect(name)}\
      """

      %__MODULE__{message: message}
    end

    def exception({@chat_input, name}) do
      message = """
      Invalid application command chat input name, must be [1,32] lowercase characters long and may contain `-`s.
      Got: #{inspect(name)}\
      """

      %__MODULE__{message: message}
    end

    def exception({:option, name}) do
      message = """
      Invalid application command chat input option name, must be [1,32] lowercase characters long and may contain `-`s.
      Got: #{inspect(name)}\
      """

      %__MODULE__{message: message}
    end

    def exception({:choice, name}) do
      message = """
      Invalid option choice name, must be [1,100] characters long.
      Got: #{inspect(name)}\
      """

      %__MODULE__{message: message}
    end

    def exception({type, name}) when type in [@user, @message] do
      type = if type == @user, do: "user", else: "message"

      message = """
      Invalid application command #{type} name, must be [1,32] characters long.
      Got: #{inspect(name)}\
      """

      %__MODULE__{message: message}
    end

    @doc """
    Whether the given name is valid.

    For choice names: The name must be [1,100] characters long
    For all else: The name must be [1,32] characters long.
    For chat inputs additionally: The name must only consist of lowercase characters or `-`.
    """
    @doc since: "0.1.0"
    @spec valid?(type :: :choice | pos_integer(), String.t()) :: boolean()
    def valid?(@chat_input, name) do
      String.valid?(name) and Regex.match?(~r/^[\p{Ll}\p{Lo}\p{N}_-]{1,32}$/u, name)
    end

    def valid?(:choice, name) do
      InvalidDescription.valid?(name)
    end

    def valid?(type, name) when type in [@user, @message] do
      with true <- String.valid?(name) do
        length = String.length(name)
        length > 0 and length <= 32
      end
    end
  end

  defmodule InvalidDefaultPermission do
    @moduledoc since: "0.1.0"
    @moduledoc """
    Raised when an invalid `@default_permission` was specified for an application command chat input.
    I.e. not a boolean.
    See: `valid?/1`
    """
    defexception [:message]

    @impl true
    def exception(default_permission) do
      message = """
      Invalid application command chat input default_permission, must be a boolean.
      Got: #{inspect(default_permission)}\
      """

      %__MODULE__{message: message}
    end

    @doc """
    Whether th given term is a valid default permission.
    """
    @doc since: "0.1.0"
    @spec valid?(term) :: boolean()
    def valid?(term)
    def valid?(nil), do: true
    def valid?(true), do: true
    def valid?(false), do: true
    def valid?(_other), do: false
  end

  defmodule InvalidChoice do
    @moduledoc since: "0.1.0"
    @moduledoc """
    Raised when an invalid application command chat input choice name or description was specified.
    Also raised when too many or duplicated choices were specified.
    See `valid_name?/1` and `valid_choice?/2`
    """
    defexception [:message]

    @string 3
    @integer 4
    @number 10

    @impl true
    def exception({:value, @string, value}) do
      message = """
      Invalid option choice value, must be [1,100] characters long.
      Got: #{inspect(value)}\
      """

      %__MODULE__{message: message}
    end

    def exception({:value, @integer, value}) do
      message = """
      Invalid option choice value, must be an integer in [-2^53,+2^53].
      Got: #{inspect(value)}\
      """

      %__MODULE__{message: message}
    end

    # @number
    def exception({:value, @number, value}) do
      message = """
      Invalid option choice value, must be a double in [-2^53,+2^53].
      Got: #{inspect(value)}\
      """

      %__MODULE__{message: message}
    end

    @doc """
    Whether the given value is valid for a chat input choice value.
    Choice value validity depend on their enclosing option:
    - `string/3` -> must be a [1,100] characters long string
    - `integer/3` -> must be an integer in [-2^53,+2^53]
    - `number/3` -> must be a double in [-2^53,+2^53]
    """
    @doc since: "0.1.0"
    @spec valid_value?(type :: number(), value :: term()) :: boolean()
    def valid_value?(type, value)

    def valid_value?(@string, value) do
      InvalidDescription.valid?(value)
    end

    def valid_value?(@integer, value) do
      is_integer(value) and abs(value) <= 9_007_199_254_740_992
    end

    def valid_value?(@number, value) do
      (is_integer(value) or is_float(value)) and abs(value) <= 9_007_199_254_740_992
    end
  end

  defmodule InvalidState do
    @moduledoc since: "0.1.0"
    @moduledoc """
    Raised when an option is specified where it's not valid.
    E.g. when a `subcommand/4` is specified after a `string/2,3` or a `choice/2` in a `subcommand/4`'s do block.
    Also raised when an invalid option modifier was specified.
    E.g. when `@required` is used where it's not allowed.
    Also raised when too many or duplicated options were specified.
    """
    defexception [:message]

    @impl true
    def exception({:limit, :option}) do
      message = """
      Options are limited to 25.\
      """

      %__MODULE__{message: message}
    end

    def exception({:limit, :choice}) do
      message = """
      Choices are limited to 25.\
      """

      %__MODULE__{message: message}
    end

    def exception(:autocomplete) do
      message = "@autocomplete is only valid for string, integer, and number options."

      %__MODULE__{message: message}
    end

    def exception({:autocomplete, :choices}) do
      message = "@autocomplete and choices are mutually exclusive."

      %__MODULE__{message: message}
    end

    def exception(:required) do
      message = "@required is only valid for options."

      %__MODULE__{message: message}
    end

    def exception(:required_change) do
      message = "Can't have required after optional options."

      %__MODULE__{message: message}
    end

    def exception({expected, got}) when is_atom(expected) do
      message = """
      Can't mix different states.
      Expected: #{expected}
      Got: #{got}\
      """

      %__MODULE__{message: message}
    end

    def exception({expected, got}) when is_list(expected) do
      message = """
      Expected one of the #{inspect(expected)} states.
      Got: #{inspect(got)}\
      """

      %__MODULE__{message: message}
    end
  end
end
