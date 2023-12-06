defmodule DisbursementsApi.Repo.Migrations.CreateDisbursementTable do
  use Ecto.Migration

  def change do
    create table(:disbursements) do
      add :merchant_id, references(:merchants, on_delete: :nothing), null: false
      add :total_commission, :decimal, null: false
      add :disbursement_date, :date, null: false
      add :orders, {:array, :map}, null: false
      add :reference, :string, null: false
      add :amount, :decimal, null: false
      add :fees, :decimal, null: false

      timestamps()
    end
  end
end
