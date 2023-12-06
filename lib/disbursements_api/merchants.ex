defmodule DisbursementsApi.Merchants do
  use Ecto.Schema
  import Ecto.Changeset

  alias DisbursementsApi.Repo

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

  def insert_orders_from_csv(file_path) do
    csv_data = DisbursementsApi.CSVParser.parse_csv(file_path)

    Enum.each(csv_data, fn order_attrs ->
      changeset = %__MODULE__{}
                   |> DisbursementsApi.Merchants.changeset(order_attrs)
      Repo.insert(changeset)
    end)
  end
end
