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

  defp parse_csv(file_path) do
    file_path
    |> File.stream!()
    |> Enum.drop(1)  # Skip the first line
    |> CSV.decode(separator: ";", headers: false)
    |> Enum.map(&extract_csv_row/1)
    |> Enum.map(&handle_csv_row/1)
  end

  defp extract_csv_row({:ok, [csv_row]}), do: [csv_row]
  defp extract_csv_row(_), do: %{}

  defp handle_csv_row([csv_row]) do
    [csv_id, reference, email, live_on, disbursement_frequency, minimum_monthly_fee] = String.split(csv_row, ";")
    %{
      "csv_id" => csv_id,
      "reference" => reference,
      "email" => email,
      "live_on" => live_on,
      "disbursement_frequency" => disbursement_frequency,
      "minimum_monthly_fee" => String.to_float(minimum_monthly_fee)
    }
  end

  def insert_orders_from_csv(file_path) do
    csv_data = parse_csv(file_path)

    Enum.each(csv_data, fn order_attrs ->
      changeset = %__MODULE__{}
                   |> DisbursementsApi.Merchants.changeset(order_attrs)
      Repo.insert(changeset)
    end)
  end
end
