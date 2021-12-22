if Code.ensure_loaded?(Plug) and Code.ensure_loaded?(Crux.Crypto) do
  defmodule Crux.Interaction.Plug.VerifyHeader do
    @signature_header_name "x-signature-ed25519"
    @timestamp_header_name "x-signature-timestamp"

    @failed_verification_code 401

    @moduledoc """
    Verifies the `#{@signature_header_name}` and `#{@timestamp_header_name}` headers Discord sends
    along every payload to ensure that only requests that are coming from Discord are processed.

    If verification fails, this plug logs a warn and responds with `#{@failed_verification_code}`.
    Note that Discord automatically tests your endpoint using invalid headers to ensure this check is working.

    If the http verb is not `POST`, this plug acts as a noop.

    ### Examples

    ```elixir
    plug Crux.Interaction.Plug.VerifyHeader, public_key: "some-public-key"

    # For runtime configuration
    plug Crux.Interaction.Plug.VerifyHeader, public_key: {__MODULE__, :fetch_public_key!, []}
    ```

    > Make sure you properly configured `Crux.Interaction.Plug.CacheBodyReader`, otherwise an error will be raised.

    > In order to use this plug, you need to add `plug` and [`crux_crypto`](https://github.com/spaceeec/crux_crypto) to your dependencies.


    ### Errors

    There currently are the following errors (for the sake of documenting them):
    - `:missing_timestamp` - When the `#{@timestamp_header_name}` header is missing
    - `:missing_signature` - When the `#{@signature_header_name}` header is missing
    - `:malformed_signature` - When the signature couldn't be decoded
    - `:mismatching_signature` - When the signature was invalid

    """
    @moduledoc since: "0.1.0"

    @behaviour Plug

    alias Crux.Crypto
    alias Plug.Conn

    require Logger

    @doc false
    @impl Plug
    def init(opts) do
      case opts[:public_key] do
        raw_public_key when is_binary(raw_public_key) ->
          public_key = decode_public_key!(raw_public_key)
          %{public_key: {:decoded, public_key}}

        {m, f, a} = mfa when is_atom(m) and is_atom(f) and is_list(a) ->
          %{public_key: {:mfa, mfa}}

        nil ->
          raise ArgumentError, ":public_key is required"

        other ->
          raise ArgumentError, """
          Expected :public_key to be either a hex encoded binary (as received from Discord),\
          or a mfa tuple to fetch it during runtime.

          Received: #{inspect(other)}
          """
      end
    end

    defp fetch_public_key!({:decoded, public_key}), do: public_key

    defp fetch_public_key!({:mfa, {m, f, a}}) do
      apply(m, f, a)
      |> decode_public_key!()
    end

    defp decode_public_key!(raw_public_key) do
      case Base.decode16(raw_public_key, case: :mixed) do
        {:ok, public_key} ->
          public_key

        :error ->
          raise ArgumentError, "failed to decode the provided :public_key"
      end
    end

    @doc false
    @impl Plug
    def call(%{method: method} = conn, _opts) when method != "POST" do
      conn
    end

    def call(
          %{
            req_headers: req_headers
          } = conn,
          %{public_key: public_key}
        ) do
      public_key = fetch_public_key!(public_key)

      with message <- fetch_body!(conn),
           {:ok, timestamp} <- fetch_timestamp(req_headers),
           {:ok, raw_signature} <- fetch_signature(req_headers),
           {:ok, signature} <- parse_signature(raw_signature),
           :ok <- verify_signature(timestamp <> message, signature, public_key) do
        conn
      else
        {:error, reason} ->
          Logger.warn(fn ->
            "Verifying the signature failed with reason: #{reason}"
          end)

          conn
          |> Conn.put_resp_content_type("application/json")
          |> Conn.send_resp(@failed_verification_code, ~s'{"message": "verification failed"}')
          |> Conn.halt()
      end
    end

    defp fetch_body!(%{body_params: %Plug.Conn.Unfetched{}}) do
      raise "Failed to read the cached body, did you forget to configure Crux.Interaction.Plug.CacheBodyReader?"
    end

    defp fetch_body!(conn) do
      Crux.Interaction.Plug.CacheBodyReader.read_cached_body(conn) || ""
    end

    defp fetch_timestamp(req_headers) do
      case List.keyfind(req_headers, @timestamp_header_name, 0, :error) do
        {@timestamp_header_name, timestamp} ->
          {:ok, timestamp}

        :error ->
          {:error, :missing_timestamp}
      end
    end

    defp fetch_signature(req_headers) do
      case List.keyfind(req_headers, @signature_header_name, 0, :error) do
        {@signature_header_name, raw_signature} ->
          {:ok, raw_signature}

        :error ->
          {:error, :missing_signature}
      end
    end

    defp parse_signature(hex_signature) do
      with :error <- Base.decode16(hex_signature, case: :mixed) do
        {:error, :malformed_signature}
      end
    end

    defp verify_signature(message, signature, public_key) do
      with :error <- Crypto.crypto_sign_verify_detached(message, signature, public_key) do
        {:error, :mismatching_signature}
      end
    end
  end
end
