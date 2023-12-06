defmodule DisbursementsApi.Merchants do
  use Ecto.Schema
  import Ecto.Changeset

  schema "merchants" do
    field :csv_id, :string
    field :reference, :string
    field :email, :string
    field :live_on, :date
    field :disbursement_frequency, :string
    field :minimum_monthly_fee, :float

    timestamps()
  end

  @doc false
  def changeset(merchant, attrs) do
    merchant
    |> cast(attrs, [:csv_id, :reference, :email, :live_on, :disbursement_frequency, :minimum_monthly_fee])
    |> validate_required([:csv_id, :reference, :email, :disbursement_frequency])
  end
end
