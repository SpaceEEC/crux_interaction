if Code.ensure_loaded?(Plug) do
  defmodule Crux.Interaction.Plug do
    @moduledoc """
      Wrapper plug around `Crux.Interaction.Executor`.

      You need to supply an executor module as `:executor` to this plug.

      ```elixir
      plug Crux.Interaction.Plug, executor: Your.Executor
      ```

      Note that handler functions will receive a context with a `conn` key.
      If handler functions return a new context it _must_ include that `conn` key with the (updated) conn struct.

      > Responds with `405` if the http verb is not `POST`.

    > In order to use this plug, you need to add `plug` to your dependencies.
      If you want to respond with files, you also need to add [`mimerl`](https://github.com/benoitc/mimerl) and [`hackney`](https://github.com/benoitc/hackney) (for `hackney_multipart`) to your dependencies.

    """
    @moduledoc since: "0.1.0"

    alias :mimerl, as: Mimerl
    alias :hackney_multipart, as: HackneyMultipart

    @behaviour Plug

    @doc false
    @impl Plug
    def init(opts) do
      opts = Map.new(opts)

      unless Map.has_key?(opts, :executor) do
        raise ArgumentError, """
        The `:executor` option is required.\
        """
      end

      unless is_atom(opts.executor) do
        raise ArgumentError, """
        The `:executor` option must be a module.
        Received #{inspect(opts.executor)}\
        """
      end

      opts
    end

    @doc false
    @impl Plug
    def call(%{method: method} = conn, _opts)
        when method != "POST" do
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(405, "{}")
    end

    def call(%{body_params: interaction} = conn, opts) do
      interaction = Crux.Interaction.Util.atomify(interaction)

      {conn, status, response, content_type} =
        Crux.Interaction.Executor.execute(opts.executor, interaction, %{conn: conn})
        |> case do
          {:ok, %{data: %{files: _}} = response, %{conn: conn}} ->
            build_multipart_response!(response, conn)

          {:ok, response, %{conn: conn}} ->
            {conn, 200, Crux.Interaction.json_library().encode!(response), "application/json"}

          {:error, :unknown_type, %{conn: conn}} ->
            {conn, 422, "{}", "application/json"}

          {:error, :unhandled_type, %{conn: conn}} ->
            {conn, 422, "{}", "application/json"}

          {:error, :unknown_command, %{conn: conn}} ->
            {conn, 404, "{}", "application/json"}

          {:error, :unhandled_command, %{conn: conn}} ->
            {conn, 404, "{}", "application/json"}

          {:error, _reason, %{conn: conn}} ->
            {conn, 500, "{}", "application/json"}
        end

      conn
      |> Plug.Conn.put_resp_content_type(content_type)
      |> Plug.Conn.send_resp(status, response)
    end

    unless Code.ensure_loaded?(Mimerl) and Code.ensure_loaded?(HackneyMultipart) do
      defp build_multipart_response!(_response, _conn) do
        raise ":mimerl and :hackney (multipart) must be installed in order to be able to respond with files."
      end
    else
      defp build_multipart_response!(response, conn) do
        boundary = HackneyMultipart.boundary()

        {body, _size} =
          response
          |> resolve_files()
          |> HackneyMultipart.encode_form(boundary)

        {conn, 200, body, "multipart/form-data; boundary=#{boundary}"}
      end

      # Borrowed from crux_rest
      def resolve_files(%{data: %{files: files} = data} = response) do
        {multipart_files, attachments} =
          files
          |> Enum.with_index()
          |> Enum.reduce({[], []}, fn
            {file, index}, {multipart_files, attachments} ->
              {attachment, name, attachments} =
                case file do
                  {attachment, name} ->
                    {attachment, name, attachments}

                  {attachment, name, description} ->
                    {attachment, name,
                     [%{id: index, filename: name, description: description} | attachments]}
                end

              disposition =
                {"form-data", [{"name", "\"files[#{index}]\""}, {"filename", "\"#{name}\""}]}

              headers = [{:"content-type", Mimerl.filename(name)}]
              multipart_file = {name, attachment, disposition, headers}

              {[multipart_file | multipart_files], attachments}
          end)

        data =
          if attachments != [] do
            Map.put(data, :attachments, attachments)
          else
            data
          end

        data = Map.delete(data, :files)

        payload_json =
          %{response | data: data}
          |> Crux.Interaction.json_library().encode!()

        form_data = [
          {"payload_json", payload_json, [{:"content-type", "application/json"}]}
          | multipart_files
        ]

        form_data
      end
    end
  end
end
