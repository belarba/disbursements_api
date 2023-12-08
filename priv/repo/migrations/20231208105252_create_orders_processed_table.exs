defmodule DisbursementsApi.Repo.Migrations.CreateOrdersProcessedTable do
  use Ecto.Migration

  def change do
    create table(:orders_processed) do
      add :amount, :float
      add :commission, :float
      add :disbursement_id, references(:disbursements, on_delete: :nothing)
      add :order_id, references(:orders, on_delete: :nothing)

      timestamps()
    end

    create index(:orders_processed, [:order_id, :disbursement_id])
  end
end
