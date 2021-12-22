# Module is named Bpplication instead of Application to not mess with autocomplete suggestions
# It's private anyway
defmodule Crux.Interaction.Bpplication do
  @moduledoc false
  @moduledoc since: "0.1.0"

  use Application

  @impl true
  def start(_type, _args) do
    Supervisor.start_link(
      [Crux.Interaction.Executor.Server],
      strategy: :one_for_one
    )
  end
end
