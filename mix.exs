defmodule Exvalid.MixProject do
  use Mix.Project

  def project do
    [
      app: :exvalid,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: [
        {:witchcraft, "~> 1.0"}
      ]
    ]
  end
end
