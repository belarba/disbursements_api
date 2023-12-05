defmodule DisbursementsApi.Repo do
  use Ecto.Repo,
    otp_app: :disbursements_api,
    adapter: Ecto.Adapters.Postgres
end
