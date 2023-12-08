defmodule DisbursementsApi.MerchantFactory do
  defmacro __using__(_opts) do
    quote do
      def merchant_factory do
        %DisbursementsApi.Merchants{
          reference: "example_merchant",
          live_on: DateTime.utc_now(),
          email: "example@example.com",
          disbursement_frequency: "daily",
          minimum_monthly_fee: 0.0
        }
      end
    end
  end
end
