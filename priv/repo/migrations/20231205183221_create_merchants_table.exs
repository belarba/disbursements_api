defmodule DisbursementsApi.Repo.Migrations.CreateMerchantsTable do
  use Ecto.Migration

  def change do
    create table(:merchants) do
      add :csv_id, :string
      add :reference, :string, null: false
      add :email, :string,null: false
      add :live_on, :date
      add :disbursement_frequency, :string, null: false
      add :minimum_monthly_fee, :float

      timestamps()
    end
  end
end
