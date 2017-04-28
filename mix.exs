defmodule ImageLib.Mixfile do
  use Mix.Project

  def project do
    [
      app: :image_lib,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      applications: [:timex, :yamerl]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:timex, "~> 3.0"},
      {:relax_yaml, "~> 0.1.2"}
    ]
  end

  defp description do
    "Image Lib with some tools"
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "CHANGELOG*", "LICENSE*"],
      maintainers: ["happy"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/gialib/image_lib"}
    ]
  end
end
