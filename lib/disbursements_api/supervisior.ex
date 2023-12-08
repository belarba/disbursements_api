defmodule DisbursementsApi.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    children = [
      {DisbursementsApi.Scheduler, []}
    ]

    opts = [strategy: :one_for_one, name: DisbursementsApi.Supervisor]
    Supervisor.init(children, opts)
  end
end
