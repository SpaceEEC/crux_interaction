defmodule Crux.Interaction.MixProject do
  use Mix.Project

  @vsn "0.1.0-dev"
  @name :crux_interaction

  def project() do
    [
      start_permanent: Mix.env() == :prod,
      package: package(),
      app: @name,
      version: @vsn,
      elixir: "~> 1.10",
      description: "",
      source_url: "https://github.com/SpaceEEC/#{@name}/",
      homepage_url: "https://github.com/SpaceEEC/#{@name}/",
      deps: deps(),
      aliases: aliases(),
      docs: docs()
    ]
  end

  def package() do
    [
      name: @name,
      licenses: ["MIT"],
      maintainers: ["SpaceEEC"],
      links: %{
        "GitHub" => "https://github.com/SpaceEEC/#{@name}/",
        "Changelog" => "https://github.com/SpaceEEC/#{@name}/releases/tag/#{@vsn}",
        "Documentation" => "https://hexdocs.pm/#{@name}/#{@vsn}"
      }
    ]
  end

  def application() do
    [extra_applications: [:logger]]
  end

  defp deps() do
    [
      {:ex_doc, github: "SpaceEEC/ex_doc", ref: "fix/module_nesting_duplicate"},
      {:jason, ">= 0.0.0", only: :dev}
    ]
  end

  defp aliases() do
    [docs: ["docs", &generate_config/1]]
  end

  defp docs() do
    [
      markdown_processor: {ExDoc.Markdown.Earmark, [breaks: true]},
      nest_modules_by_prefix: [
        Crux.Interaction.ApplicationCommand,
        Crux.Interaction.ApplicationCommand.Exceptions,
        Crux.Interaction.MessageComponent
      ],
      groups_for_modules: [
        Response: [
          Crux.Interaction.Response
        ],
      ],
      groups_for_functions: [
        "Response Types": & &1[:section] == :response,
        Autocomplete: & &1[:section] == :autocomplete,
        Modal: & &1[:section] == :modal,
        Message: & &1[:section] == :message,
        Multiple: & &1[:section] == :multiple
      ],
      formatter: "html",
      source_ref: "trunk"
    ]
  end

  def generate_config(_) do
    config =
      System.cmd("git", ["tag"])
      |> elem(0)
      |> String.split("\n")
      |> Enum.slice(0..-2)
      |> Enum.map(&%{"url" => "https://hexdocs.pm/#{@name}/" <> &1, "version" => &1})
      |> Enum.reverse()
      |> Jason.encode!()

    config = "var versionNodes = " <> config

    path =
      __DIR__
      |> Path.split()
      |> Kernel.++(["doc", "docs_config.js"])
      |> Path.join()

    File.write!(path, config)

    Mix.Shell.IO.info("Generated #{path}")
  end
end
