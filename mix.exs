defmodule TimeSync.MixProject do
  use Mix.Project

  def project do
    [
      app: :time_sync,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {TimeSync.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ab_http, "~> 0.2.7", git: "https://gitlab.com/abirvalarg/ab_http"}
    ]
  end
end
