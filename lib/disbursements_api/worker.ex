defmodule DisbursementsApi.Worker do
  use GenServer

  @impl false
  def start_link(arg) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    :timer.send_interval(86_400_000, :work)
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    DisbursementsApi.DisbursementCalculator.today_disbursements()
    {:noreply, state}
  end
end
