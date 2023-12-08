defmodule DisbursementsApi.OrderFactory do
  defmacro __using__(_opts) do
    quote do
      def order_factory do
        %DisbursementsApi.Orders{
          amount: "100",
          merchant_reference: build(:merchant).reference,
          csv_created_at: DateTime.add(DateTime.utc_now(), -60 * 24 * 60 * 60),
        }
      end
    end
  end
end
