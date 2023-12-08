defmodule DisbursementsApi.OrdersProcessed do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders_processed" do
    field :amount, :float
    field :commission, :float
    field :disbursement_id, references(:disbursements, on_delete: :nothing)
    field :order_id, references(:orders, on_delete: :nothing)

    timestamps()
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [:amount, :commission, :disbursement_id, :order_id])
    |> validate_required([:amount, :commission, :disbursement_id, :order_id])
  end
end
