defmodule Crux.Interaction.ApplicationCommand.ContextMenu do
  @moduledoc false
  @moduledoc since: "0.1.0"

  alias Crux.Interaction.ApplicationCommand.Exceptions.{InvalidName, InvalidDescription}

  defmacro __using__(type) do
    quote do
      @behaviour Crux.Interaction.ApplicationCommand

      @__crux_interaction_data__ %{
        # name
        type: unquote(type)
      }

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      name = Module.get_attribute(__MODULE__, :name)

      unless InvalidName.valid?(@__crux_interaction_data__.type, name) do
        raise InvalidName, {@__crux_interaction_data__.type, name}
      end

      if Module.has_attribute?(__MODULE__, :description) do
        raise InvalidDescription, :context_menu
      end

      @__crux_interaction_data__ Map.put(@__crux_interaction_data__, :name, name)

      def __crux_command__() do
        @__crux_interaction_data__
      end
    end
  end
end
