defmodule Crux.Interaction.ApplicationCommand.ChatInput do
  @moduledoc since: "0.1.0"
  @moduledoc File.read!(Path.rootname(__ENV__.file) <> ".md")
  @external_resource Path.rootname(__ENV__.file) <> ".md"

  alias Crux.Interaction.ApplicationCommand.Exceptions.{
    InvalidName,
    InvalidDescription,
    InvalidDefaultPermission,
    InvalidChoice,
    InvalidState
  }

  defmodule Scope do
    @moduledoc false
    @moduledoc since: "0.1.0"
    defstruct(
      state: nil,
      size: 0,
      choices: [],
      options: [],
      required: true
    )

    def put_option(%Scope{choices: [], options: options} = scope, option) do
      if Enum.any?(options, &(&1.name == option.name)) do
        raise InvalidName, {:duplicate, :option, option.name}
      else
        if scope.size >= 25 do
          raise InvalidState, {:limit, :option}
        end

        %{scope | options: [option | options], size: scope.size + 1}
      end
    end

    def put_choice(%Scope{choices: choices, options: []} = scope, choice) do
      if Enum.any?(choices, &(&1.name == choice.name)) do
        raise InvalidName, {:duplicate, :choice, choice.name}
      else
        if scope.size >= 25 do
          raise InvalidState, {:limit, :choice}
        end

        %{scope | choices: [choice | choices], size: scope.size + 1}
      end
    end

    def put_required(%Scope{required: c_required} = scope, n_required)
        when is_boolean(n_required) do
      if not c_required and n_required do
        raise InvalidState, :required_change
      else
        %{scope | required: n_required}
      end
    end

    def put_required(_scope, required) do
      raise ArgumentError, "@required must be a boolean, received: #{inspect(required)}"
    end
  end

  @empty_do [do: nil]

  # command types
  @chat_input 1
  # @user 2
  # @message 3

  # Option Types
  @subcommand 1
  @subcommand_group 2
  @string 3
  @integer 4
  @boolean 5
  @user 6
  @channel 7
  @role 8
  @mentionable 9
  @number 10

  # States
  @state_start :start
  @state_subcommand_group :subcommand_group
  @state_subcommand :subcommand
  @state_option :option
  @state_choice :choice

  # State -> State (when going down a layer, otherwise it must be same)
  @transitions %{
                 @state_start => [@state_subcommand_group, @state_subcommand, @state_option],
                 @state_subcommand_group => [@state_subcommand],
                 @state_subcommand => [@state_option],
                 @state_option => [@state_choice],
                 @state_choice => []
               }
               |> Macro.escape()

  # Type -> State
  @type_to_state %{
    @subcommand => @state_subcommand,
    @subcommand_group => @state_subcommand_group,
    @string => @state_option,
    @integer => @state_option,
    @boolean => @state_option,
    @user => @state_option,
    @channel => @state_option,
    @role => @state_option,
    @mentionable => @state_option,
    @number => @state_option
  }

  @autocompletables [@string, @integer, @number]

  defmacro __using__([]) do
    # Can't put this outside of __using__ due do Scope not being defined yet.
    default_scope = Macro.escape(%Scope{state: @state_start})

    quote do
      @behaviour Crux.Interaction.ApplicationCommand
      import unquote(__MODULE__)

      @__crux_interaction_data__ %{
        # name
        # description
        # options
        # default_permission
        type: unquote(@chat_input)
      }

      @__crux_interaction_scope__ unquote(default_scope)
      # true => check @transitions; false => type must match current state
      @__crux_interaction_entry__ true

      @before_compile unquote(__MODULE__)
    end
  end

  @doc """
  Defines a sub command option.

  ```elixir
  subcommand "create", "Creates... something!" do
    # Optionally further options
  end
  ```
  """
  @doc since: "0.1.0"
  defmacro subcommand(name, description, [do: _block] = do_block \\ @empty_do) do
    put_option(@subcommand, name, description, do_block)
  end

  @doc """
  Defines a sub command group option.

  ```elixir
  subcommand_group "create", "Creates... something!" do
    # Required sub commands
  end
  """
  @doc since: "0.1.0"
  defmacro subcommand_group(name, description, [do: _block] = do_block) do
    put_option(@subcommand_group, name, description, do_block)
  end

  @doc """
  Defines a string option, can optionally be `@required true` and `@autocomplete true`.

  ```elixir
  @required true
  string "name", "The name of the thing you want to create."
  ```

  You can optionally define choices the user has to pick one from, see `choice/2`.
  """
  @doc since: "0.1.0"
  defmacro string(name, description, [do: _block] = do_block \\ @empty_do) do
    put_option(@string, name, description, do_block)
  end

  @doc """
  Defines an integer option, can optionally be `@required true` and `@autocomplete true`.

  ```elixir
  @required true
  integer "amount", "The amount of 🧀 you want to donate."
  ```

  You can optionally define choices the user has to pick one from, see `choice/2`.
  """
  @doc since: "0.1.0"
  defmacro integer(name, description, [do: _block] = do_block \\ @empty_do) do
    put_option(@integer, name, description, do_block)
  end

  @doc """
  Defines a boolean option, can optionally be `@required true`.

  ```elixir
  @required true
  boolean "enabled", "Whether you want to enable or disable this."
  ```
  """
  @doc since: "0.1.0"
  defmacro boolean(name, description) do
    put_option(@boolean, name, description, @empty_do)
  end

  @doc """
  Defines a user option, can optionally be `@required true`.

  ```elixir
  @required true
  user "user", "The user you want to interact with."
  ```
  """
  @doc since: "0.1.0"
  defmacro user(name, description) do
    put_option(@user, name, description, @empty_do)
  end

  @doc """
  Defines a channel option, can optionally be `@required true`.

  ```elixir
  @required true
  channel "channel", "The channel you notifications to be sent to."
  ```
  """
  @doc since: "0.1.0"
  defmacro channel(name, description) do
    put_option(@channel, name, description, @empty_do)
  end

  @doc """
  Defines a role option, can optionally be `@required true`.

  ```elixir
  @required true
  role "role", "The role you want to be mentioned alongside notifications."
  ```
  """
  @doc since: "0.1.0"
  defmacro role(name, description) do
    put_option(@role, name, description, @empty_do)
  end

  @doc """
  Defines a mentionable option, this is an union of `user/2` and `role/2`, can optionally be `@required true`.

  ```elixir
  @required true
  mentionable "target", "The user or role to block from this channel"
  ```
  """
  @doc since: "0.1.0"
  defmacro mentionable(name, description) do
    put_option(@mentionable, name, description, @empty_do)
  end

  @doc """
  Defines a number option, can optionally be `@required true` and `@autocomplete true`.

  ```elixir
  @required true
  number "number", "Give me some number"
  ```

  You can optionally define choices the user has to pick one from, see `choice/2`.
  """
  @doc since: "0.1.0"
  defmacro number(name, description, [do: _block] = do_block \\ @empty_do) do
    put_option(@number, name, description, do_block)
  end

  @doc """
  Defines choices for `string/3`, `integer/3`, and `number/3` options.

  Note that this is mutually exclusive with `@autocomplete true`.

  ```elixir
  string "foo", "foos" do
      choice "bar", "bar"
      choice "baz", "baz"
  end

  integer "foo", "foos" do
    choice "bar", 1
    choice "baz", 2
  end

  number "foo", "foos" do
    choice "bar", 1
    choice "baz", 1.5
  end
  ```
  """
  @doc since: "0.1.0"
  defmacro choice(name, value) do
    quote do
      handle_entry(unquote(@state_choice))

      name = unquote(name)
      value = unquote(value)

      unless InvalidName.valid?(:choice, name) do
        raise InvalidName, {:choice, name}
      end

      unless InvalidChoice.valid_value?(@__crux_interaction_parent_type__, value) do
        raise InvalidChoice, {:value, @__crux_interaction_parent_type__, value}
      end

      choice = %{
        name: name,
        value: value
      }

      if Module.has_attribute?(__MODULE__, :required) do
        raise InvalidState, :required
      end

      @__crux_interaction_scope__ @__crux_interaction_scope__
                                  |> Scope.put_choice(choice)
    end
  end

  defp put_option(type, name, description, do: do_block) do
    next_state = Map.fetch!(@type_to_state, type)
    do_block? = do_block != nil

    quote do
      # Checks whether the next state is allowed,
      # additionally, if going down a layer, sets a new scope
      handle_entry(unquote(next_state))

      required = Module.delete_attribute(__MODULE__, :required)
      autocomplete = Module.delete_attribute(__MODULE__, :autocomplete)

      if not is_nil(required) and unquote(next_state) != unquote(@state_option) do
        raise InvalidState, :required
      end

      if not is_nil(autocomplete) and unquote(type) not in unquote(@autocompletables) do
        raise InvalidState, :autocomplete
      end

      option = %{
        type: unquote(type),
        name: unquote(name),
        description: unquote(description)
      }

      unless InvalidName.valid?(unquote(@chat_input), option.name) do
        raise InvalidName, {:option, option.name}
      end

      unless InvalidDescription.valid?(option.description) do
        raise InvalidDescription, {:option, option.description}
      end

      alias Crux.Interaction.Util

      option =
        option
        |> Util.put_if(
          :required,
          required,
          &(not is_nil(&1))
        )
        |> Util.put_if(
          :autocomplete,
          autocomplete,
          &(not is_nil(&1))
        )

      alias Crux.Interaction.ApplicationCommand.ChatInput.Scope
      scope = Scope.put_required(@__crux_interaction_scope__, required || false)

      option =
        if unquote(do_block?) do
          @__crux_interaction_entry__ true
          # This attribute is used to validate choice types
          @__crux_interaction_parent_type__ unquote(type)

          # This overwrites @__crux_interaction_scope__, if any option is provided
          unquote(do_block)

          Module.delete_attribute(__MODULE__, :__crux_interaction_parent_type__)
          @__crux_interaction_entry__ false

          alias Crux.Interaction.Util

          option
          |> Util.put_if(
            :options,
            Enum.reverse(@__crux_interaction_scope__.options),
            &(&1 != [])
          )
          |> Util.put_if(
            :choices,
            Enum.reverse(@__crux_interaction_scope__.choices),
            &(&1 != [])
          )
        else
          option
        end

      if option[:autocomplete] && option[:choices] not in [nil, []] do
        raise InvalidState, {:autocomplete, :choices}
      end

      @__crux_interaction_scope__ Scope.put_option(scope, option)
    end
  end

  @doc false
  @doc since: "0.1.0"
  defmacro handle_entry(next_state) do
    quote do
      current_state = @__crux_interaction_scope__.state

      if @__crux_interaction_entry__ do
        valid_states = Map.fetch!(unquote(@transitions), current_state)

        unless unquote(next_state) in valid_states do
          raise InvalidState, {valid_states, unquote(next_state)}
        end

        @__crux_interaction_scope__ %Scope{
          state: unquote(next_state)
        }
        @__crux_interaction_entry__ false
      else
        unless current_state == unquote(next_state) do
          raise InvalidState, {current_state, unquote(next_state)}
        end
      end
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      name = Module.get_attribute(__MODULE__, :name)
      description = Module.get_attribute(__MODULE__, :description)
      default_permission = Module.get_attribute(__MODULE__, :default_permission)

      unless InvalidName.valid?(unquote(@chat_input), name) do
        raise InvalidName, {unquote(@chat_input), name}
      end

      unless InvalidDescription.valid?(description) do
        raise InvalidDescription, description
      end

      unless InvalidDefaultPermission.valid?(default_permission) do
        raise InvalidDefaultPermission, default_permission
      end

      scope = Module.delete_attribute(__MODULE__, :__crux_interaction_scope__)
      Module.delete_attribute(__MODULE__, :__crux_interaction_entry__)

      alias Crux.Interaction.Util

      @__crux_interaction_data__ @__crux_interaction_data__
                                 |> Map.put(:name, name)
                                 |> Map.put(:description, description)
                                 |> Util.put_if(
                                   :options,
                                   Enum.reverse(scope.options),
                                   &(&1 != [])
                                 )
                                 |> Util.put_if(
                                   :default_permission,
                                   default_permission,
                                   &(not is_nil(&1))
                                 )

      def __crux_command__() do
        @__crux_interaction_data__
      end
    end
  end
end
