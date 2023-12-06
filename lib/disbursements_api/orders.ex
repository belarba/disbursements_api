defmodule DisbursementsApi.Orders do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :csv_id, :string
    field :merchant_reference, :string
    field :amount, :float

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:csv_id, :merchant_reference, :amount])
    |> validate_required([:csv_id, :merchant_reference, :amount])
  end
end
