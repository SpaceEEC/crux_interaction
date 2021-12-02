defmodule Crux.Interaction.Util do
  @moduledoc false
  @moduledoc since: "0.1.0"

  @doc "Puts `val` in `map` under `key`, if `pred` applied with `val` returns `true`."
  @doc since: "0.1.0"
  @spec put_if(map(), key :: term(), value, (value -> as_boolean(term()))) ::
          map()
        when value: term()
  def put_if(map, key, val, pred) do
    if pred.(val) do
      Map.put(map, key, val)
    else
      map
    end
  end
end
