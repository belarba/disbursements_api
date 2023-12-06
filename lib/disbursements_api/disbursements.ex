defmodule DisbursementsApi.Disbursement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "disbursements" do
    field :merchant_id, :integer
    field :total_commission, :decimal
    field :disbursement_date, :date
    field :orders, {:array, :map}

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:merchant_id, :total_commission, :disbursement_date, :orders])
    |> validate_required([:merchant_id, :total_commission, :disbursement_date, :orders])
  end
end