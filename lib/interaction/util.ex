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

  @doc false
  @spec atomify(input :: struct() | map() | list()) :: map() | list()
  def atomify(input)
  def atomify(%{__struct__: _struct} = struct), do: struct |> Map.from_struct() |> atomify()
  def atomify(%{} = map), do: Map.new(map, &atomify_kv/1)
  def atomify(list) when is_list(list), do: Enum.map(list, &atomify/1)
  def atomify(other), do: other

  defp atomify_kv({k, v}) when is_atom(k), do: {k, atomify(v)}

  defp atomify_kv({<<c::utf8, _rest::binary>> = k, v}) when c in ?0..?9 do
    new_k =
      case Integer.parse(k) do
        {new_k, ""} -> new_k
        _ -> String.to_atom(k)
      end

    {new_k, atomify(v)}
  end

  defp atomify_kv({k, v}) when is_binary(k), do: {String.to_atom(k), atomify(v)}
  defp atomify_kv({k, v}), do: {k, atomify(v)}
end
