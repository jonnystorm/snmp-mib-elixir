defmodule SNMPMIB.Mixfile do
  use Mix.Project

  def project do
    [ app: :snmp_mib_ex,
      version: "0.0.3",
      name: "SNMPMIB",
      source_url: "https://github.com/jonnystorm/snmp-mib-elixir",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      docs: [extras: ["README.md"]]
    ]
  end

  defp get_application(:prod) do
    [applications: [:logger]]
  end
  defp get_application(_) do
    [applications: [:logger]]
  end

  def application do
    get_application Mix.env
  end

  defp deps do
    [ {:ex_doc, "~> 0.15", only: :dev}
    ]
  end
end
