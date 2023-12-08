defmodule DisbursementsApi.Factory do
  use ExMachina.Ecto, repo: DisbursementsApi.Repo
  use DisbursementsApi.MerchantFactory
  use DisbursementsApi.OrderFactory
end
