defmodule DisbursementsApi.Repo.Migrations.AddProcessedFlagToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :processed, :boolean, default: false
    end
  end
end
