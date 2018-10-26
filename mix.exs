defmodule Exvalid.MixProject do
  use Mix.Project

  def project do
    [
      app: :exvalid,
      version: "0.1.0",
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: [
        {:witchcraft, "~> 1.0"}
      ],
      name: "ExValid",
      source_url: "https://github.com/alinpopa/exvalid",
      docs: [
        extras: ["README.md"],
        main: "readme"
      ]
    ]
  end

  def application() do
    []
  end

  defp description() do
    "Collecting errors validation ADT using Witchcraft."
  end

  defp package() do
    [
      maintainers: ["Alin Popa"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/alinpopa/exvalid"}
    ]
  end
end
