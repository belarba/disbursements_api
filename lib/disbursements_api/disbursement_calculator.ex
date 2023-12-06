defmodule DisbursementsApi.DisbursementCalculator do
  import Ecto.Query

  alias DisbursementsApi.Repo

  @spec calculate_disbursement(merchant_id :: integer, disbursement_date :: Date.t) :: :ok | {:error, String.t}
  def calculate_disbursement(merchant_id, disbursement_date) do
    # Fetch merchant and orders for the specified merchant and date
    merchant = Repo.get!(DisbursementsApi.Merchants, merchant_id)
    IO.puts("em cima")
    IO.inspect(merchant)
    orders = fetch_orders_for_disbursement(merchant)

    # Calculate total commission and apply fees
    total_commission = calculate_total_commission(orders)
    total_from_orders = Enum.reduce(orders, 0.0, fn order, acc ->
      acc + order.amount
    end)
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
      orders: orders,
      amount: round_up(total_from_orders, 2),
      fees: round_up(total_commission - adjusted_commission, 2),
      reference: "DISB-#{merchant_id}-#{disbursement_date}"
    }

    # Persist the disbursement record
    case Repo.insert(DisbursementsApi.Disbursement.changeset(%DisbursementsApi.Disbursement{}, disbursement_params)) do
      {:ok, _disbursement} -> :ok
      {:error, changeset} -> {:error, "Failed to create disbursement: #{inspect(changeset.errors)}"}
    end
  end

  defp fetch_orders_for_disbursement(merchant) do
    Repo.all(from o in DisbursementsApi.Orders,
             where: o.merchant_reference == ^merchant.reference)
  end

  defp calculate_total_commission(orders) do
    IO.puts("aqui")
    IO.inspect(orders)
    Enum.reduce(orders, 0.0, fn order, acc ->
      acc + calculate_order_commission(order)
    end)
  end

  defp calculate_order_commission(order) do
    amount = order.amount
    cond do
      amount < 50.0 -> round_up(amount * 0.01, 2)
      amount >= 50.0 and amount <= 300.0 -> round_up(amount * 0.0095, 2)
      true -> round_up(amount * 0.0085, 2)
    end
  end

  defp apply_fees(total_commission) do
    round_up(total_commission, 2)
  end

  defp first_disbursement_of_month?(merchant, disbursement_date) do
    live_on_weekday = Date.day_of_week(merchant.live_on)
    disbursement_weekday = Date.day_of_week(disbursement_date)
    live_on_weekday == disbursement_weekday
  end

  defp ensure_minimum_monthly_fee(merchant, disbursement_date, adjusted_commission) do
    last_month = Date.add(disbursement_date, -30)
    monthly_fee_threshold = round_up(merchant.minimum_monthly_fee, 2)

    previous_month_commission = calculate_previous_month_commission(merchant.id, last_month)
    remaining_fee = max(0.0, monthly_fee_threshold - previous_month_commission)

    monthly_fee = if remaining_fee > 0.0 do
      min(remaining_fee, adjusted_commission)
    else
      0.0
    end

    adjusted_commission = adjusted_commission - monthly_fee

    adjusted_commission
  end

  defp calculate_previous_month_commission(merchant_id, last_month) do
    Repo.one(
      from d in DisbursementsApi.Disbursement,
      where: d.merchant_id == ^merchant_id and fragment("DATE_PART('month', ?) = DATE_PART('month', ?)", d.disbursement_date, ^last_month),
      select: sum(d.total_commission)
    )
  end

  defp round_up(number, precision) do
    IO.puts("aqui")
    IO.inspect(number)
    IO.inspect(precision)
    round(number * (10 ** precision)) / 10 ** precision
  end
end
