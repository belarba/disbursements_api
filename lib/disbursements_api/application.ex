defmodule DisbursementsApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DisbursementsApi.Worker, 24 * 60 * 60 * 1000},
      DisbursementsApi.Repo,
      {
        Plug.Cowboy,
        scheme: :http,
        plug: DisbursementsApi.Router,
        options: [port: Application.get_env(:disbursements_api, :port)]
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DisbursementsApi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
