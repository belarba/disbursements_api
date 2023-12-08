defmodule DisbursementsApi.Repo.Migrations.ChangeFieldTypeFromAmountOnOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      modify :amount, :string
    end
  end
end
