defmodule DisbursementsApi.Disbursement do
  use Ecto.Schema
  import Ecto.{Changeset, Query}

  alias DisbursementsApi.{Repo, Merchants, Orders, OrdersProcessed, Disbursement}

  schema "disbursements" do
    field(:merchant_id, :integer)
    field(:total_commission, :decimal)
    field(:disbursement_date, :date)
    field(:reference, :string)

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:merchant_id, :total_commission, :disbursement_date, :reference])
    |> validate_required([:merchant_id, :total_commission, :disbursement_date, :reference])
  end

  def summary(disbursement) do
    %{
      reference: disbursement.reference,
      total_commission: disbursement.total_commission,
      disbursement_date: disbursement.disbursement_date
    }
  end

  def today_disbursements() do
    daily =
      Repo.all(
        from(m in Merchants,
          where: fragment("upper(?)", m.disbursement_frequency) == "DAILY",
          select: m.id
        )
      )

    weekly =
      Repo.all(
        from(m in Merchants,
          where:
            fragment("upper(?)", m.disbursement_frequency) == "WEEKLY" and
              fragment("EXTRACT(DOW FROM ?) = ?", m.live_on, ^Date.day_of_week(Date.utc_today())),
          select: m.id
        )
      )

    merchants_id = daily ++ weekly

    Enum.each(merchants_id, fn merchant_id ->
      calculate_disbursement(merchant_id, DateTime.utc_now())
    end)
  end

  @spec calculate_disbursement(merchant_id :: integer, disbursement1_date :: Date.t()) ::
          :ok | {:error, String.t()}
  def calculate_disbursement(merchant_id, disbursement_date) do
    # Fetch merchant and orders for the specified merchant and date
    merchant = Repo.get!(Merchants, merchant_id)
    orders = fetch_orders_for_disbursement(merchant.reference, disbursement_date)

    # Calculate total commission and apply fees
    total_commission = calculate_total_commission(orders)
    adjusted_commission = apply_fees(total_commission)

    # Check if it's the first disbursement of the month
    if first_disbursement_of_month?(merchant, disbursement_date) do
      ensure_minimum_monthly_fee(merchant, disbursement_date, adjusted_commission)
    end

    # Create the disbursement record
    disbursement_params = %{
      merchant_id: merchant_id,
      total_commission: adjusted_commission,
      disbursement_date: disbursement_date,
      reference: "DISB-#{merchant_id}-#{disbursement_date}"
    }

    {:ok, disbursement} = create(disbursement_params)

    Enum.each(
      orders,
      fn order ->
        Repo.insert(
          OrdersProcessed.changeset(%OrdersProcessed{}, %{
            order_id: order.id,
            disbursement_id: disbursement.id,
            amount: order.amount,
            commission: calculate_order_commission(order)
          })
        )

        Orders.changeset(order, %{processed: true})
        |> Repo.update()
      end
    )

    {:ok, disbursement}
  rescue
    error in Ecto.QueryError -> {:error, to_string(error)}
  end

  def create(attrs) do
    %Disbursement{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  defp fetch_orders_for_disbursement(merchant_reference, disbursement_date) do
    Repo.all(
      from(o in Orders,
        left_join: p in OrdersProcessed,
        on: o.id == p.order_id,
        where:
          o.merchant_reference == ^merchant_reference and
            fragment("DATE(?) <= DATE(?)", o.csv_created_at, ^disbursement_date) and
            is_nil(p.disbursement_id) and
            o.processed == false
      )
    )
  end

  defp calculate_total_commission(orders) do
    Enum.reduce(orders, 0.0, fn order, acc ->
      acc + calculate_order_commission(order)
    end)
  end

  defp calculate_order_commission(order) do
    amount = String.to_float(order.amount)

    case amount do
      _ when amount < 50.0 -> round_up(amount * 0.01, 2)
      _ when amount >= 50.0 and amount <= 300.0 -> round_up(amount * 0.0095, 2)
      _ -> round_up(amount * 0.0085, 2)
    end
  end

  defp apply_fees(total_commission) do
    round_up(total_commission, 2)
  end

  defp first_disbursement_of_month?(merchant, disbursement_date) do
    live_on_weekday = Date.day_of_week(merchant.live_on || Date.utc_today())
    disbursement_weekday = Date.day_of_week(disbursement_date)
    live_on_weekday == disbursement_weekday
  end

  defp ensure_minimum_monthly_fee(merchant, disbursement_date, adjusted_commission) do
    last_month = Date.add(disbursement_date, -30)
    monthly_fee_threshold = round_up(merchant.minimum_monthly_fee || 0.0, 2)

    previous_month_commission = calculate_previous_month_commission(merchant.id, last_month)
    remaining_fee = max(0.0, monthly_fee_threshold - previous_month_commission)

    monthly_fee =
      if remaining_fee > 0.0 do
        min(remaining_fee, adjusted_commission)
      else
        0.0
      end

    adjusted_commission = adjusted_commission - monthly_fee

    adjusted_commission
  end

  defp calculate_previous_month_commission(merchant_id, last_month) do
    Repo.one(
      from(d in Disbursement,
        where:
          d.merchant_id == ^merchant_id and
            fragment(
              "DATE_PART('month', ?) = DATE_PART('month', ?)",
              d.disbursement_date,
              ^last_month
            ),
        select: sum(d.total_commission)
      )
    )
  rescue
    _ -> 0.0
  end

  defp round_up(number, precision) do
    round(number * 10 ** precision) / 10 ** precision
  end
end
