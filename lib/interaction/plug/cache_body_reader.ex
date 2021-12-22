if Code.ensure_loaded?(Plug) do
  defmodule Crux.Interaction.Plug.CacheBodyReader do
    @moduledoc """
    To be plugged into `Plug.Parsers` as a `body_reader`.


    ```elixir
    plug Plug.Parser,
      # ...
      body_reader: {Crux.Interaction.Plug.CacheBodyReader, :read_body, []},
      # ...

    ```

    Caching the raw body prior to parsing it is necessary to be able to
    validate Discord's signature via `Crux.Interaction.Plug.VerifyHeader`.

    The raw body will then be placed into `conn.private[:raw_body]`.

    > Taken from https://hexdocs.pm/plug/Plug.Parsers.html#module-custom-body-reader and modified a bit

    > In order to use this module, you need to add `plug` to your dependencies.
    """
    @moduledoc since: "0.1.0"

    alias Plug.Conn

    @doc false
    def read_body(conn, opts) do
      case Conn.read_body(conn, opts) do
        {:ok, body, conn} ->
          body =
            [body | Map.get(conn.private, :raw_body, [])]
            |> Enum.reverse()
            |> IO.chardata_to_string()

          conn = Conn.put_private(conn, :raw_body, body)
          {:ok, body, conn}

        {:more, body, conn} ->
          conn = update_in(conn.private[:raw_body], &[body | &1 || []])
          {:more, body, conn}

        {:error, _error} = error ->
          error
      end
    end

    @doc """
    Get the cached body, returns `nil` if no body was read.
    """
    @doc since: "0.1.0"
    @spec read_cached_body(Plug.Conn.t()) :: String.t() | nil
    def read_cached_body(conn) do
      conn.private[:raw_body]
    end
  end
end
