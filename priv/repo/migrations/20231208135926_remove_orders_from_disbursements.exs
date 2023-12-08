defmodule DisbursementsApi.Repo.Migrations.RemoveOrdersFromDisbursements do
  use Ecto.Migration

  def change do
    alter table(:disbursements) do
      remove :orders
    end
  end
end
