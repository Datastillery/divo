defmodule Divo.MixProject do
  use Mix.Project

  def project do
    [
      app: :divo,
      version: "1.0.1",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      source_url: "https://github.com/SmartColumbusOS/divo"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.1"},
      {:placebo, "~> 1.2.1", only: [:dev, :test]},
      {:ex_doc, "~> 0.19", only: :dev},
      {:patiently, "~> 0.2.0"},
      {:temporary_env, "~> 2.0.1", only: [:dev, :test]}
    ]
  end

  defp description do
    "A library for easily constructing integration service dependencies in docker and orchestrating with mix."
  end

  defp package do
    [
      organization: "smartcolumbus_os",
      licenses: ["AllRightsReserved"],
      links: %{"GitHub" => "https://github.com/SmartColumbusOS/divo"}
    ]
  end
end
