defmodule DisbursementsApi.Scheduler do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    schedule_job()
    {:ok, nil}
  end

  def handle_info(:run_job, state) do
    DisbursementsApi.DisbursementCalculator.today_disbursements()
    {:noreply, state}
  end

  defp schedule_job do
    {:ok, _} = Process.send_after(self(), :run_job, time_until_next_run())
  end

  defp time_until_next_run do
    # Calculate the time until the next run (e.g., 24 hours from now)
    # Adjust the time accordingly based on your requirements
    {:ok, time} = System.os_time(:second)
    next_run_time = :calendar.local_time_to_universal_time({2023, 1, 1, 0, 0, 0}, "UTC") + 24 * 60 * 60
    next_run_time - time
  end
end
