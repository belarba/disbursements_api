defmodule DisbursementsApi.Repo.Migrations.AddCsvCreatedAtToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :csv_created_at, :date
    end
  end
end
