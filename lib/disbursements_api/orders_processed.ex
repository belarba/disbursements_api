defmodule DisbursementsApi.OrdersProcessed do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders_processed" do
    field :amount, :float
    field :commission, :float
    field :disbursement_id, :integer
    field :order_id, :integer

    timestamps()
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [:amount, :commission, :disbursement_id, :order_id])
    |> validate_required([:amount, :commission, :disbursement_id, :order_id])
  end
end
