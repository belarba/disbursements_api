defmodule DisbursementsApi.Orders do
  use Ecto.Schema
  import Ecto.Changeset

  alias DisbursementsApi.Repo

  schema "orders" do
    field :csv_id, :string
    field :merchant_reference, :string
    field :amount, :decimal

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:csv_id, :merchant_reference, :amount])
    |> validate_required([:csv_id, :merchant_reference, :amount])
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
    [csv_id, merchant_reference, amount, _date] = String.split(csv_row, ";")
    %{
      "csv_id" => csv_id,
      "merchant_reference" => merchant_reference,
      "amount" => String.to_float(amount)
    }
  end

  def insert_orders_from_csv(file_path) do
    csv_data = parse_csv(file_path)

    Enum.each(csv_data, fn order_attrs ->
      changeset = %__MODULE__{}
                   |> DisbursementsApi.Orders.changeset(order_attrs)
      Repo.insert(changeset)
    end)
  end
end
