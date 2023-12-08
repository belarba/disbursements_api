defmodule DisbursementsApi.DisbursementTest do
  use ExUnit.Case, async: true

  import Ecto.Query

  import DisbursementsApi.Factory
  alias DisbursementsApi.Disbursement
  alias DisbursementsApi.OrdersProcessed

  alias DisbursementsApi.Repo

  test "calculates disbursements for a merchant" do
    merchant = insert(:merchant)
    insert(:order, merchant_reference: merchant.reference, amount: "100.0")
    insert(:order, merchant_reference: merchant.reference, amount: "200.0")
    insert(:order, merchant_reference: merchant.reference, amount: "300.0")

    Disbursement.calculate_disbursement(merchant.id, DateTime.utc_now())

    disbursement = Repo.get_by(Disbursement, merchant_id: merchant.id)

    orders_processed =
      Repo.all(
        from(o in DisbursementsApi.OrdersProcessed,
          where: o.disbursement_id == ^disbursement.id
        )
      )

    total =
      Enum.reduce(orders_processed, 0.0, fn order_processed, acc ->
        acc + order_processed.amount
      end)

    assert total == 600.0
  end

  test "disbursements are calculated correctly for daily and weekly merchants" do
    daily_merchant =
      insert(:merchant, disbursement_frequency: "DAILY", live_on: DateTime.utc_now())

    weekly_merchant =
      insert(:merchant, disbursement_frequency: "WEEKLY", live_on: DateTime.utc_now())

    result = Disbursement.today_disbursements()

    assert result == :ok
  end
end
