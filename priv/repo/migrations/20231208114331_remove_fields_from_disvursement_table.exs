defmodule DisbursementsApi.Repo.Migrations.RemoveFieldsFromDisvursementTable do
  use Ecto.Migration

  def change do
    alter table(:disbursements) do
      remove :amount
      remove :fees
    end
  end
end
