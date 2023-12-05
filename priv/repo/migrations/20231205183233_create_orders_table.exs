defmodule DisbursementsApi.Repo.Migrations.CreateOrdersTable do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :csv_id, :string
      add :merchant_reference, :string, null: false
      add :amount, :money, null: false

      timestamps()
    end
  end
end
