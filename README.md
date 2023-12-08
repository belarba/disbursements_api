# DisbursementsApi

This repository a solution for a Disbursement process.
It was made using **Elixir** - local - and **Postgres** - under Docker


## How to Setup and Run
1. Clone this repository to your local
2. Copy `.env.manifest` file to `.env` and fill in the requested environments variables - all related to the docker address and user/password to access the db
3. Install dependencies with `mix deps.get`
4. Create and migrate the database `mix ecto.setup`
5. Start the server with `source .env && iex -S mix run`

When the server starts, a process that runs every 24h will be on
But as the database is empty - and I didn't automatize the process to upload the csv from `Orders` and `Merchats`, we need to call this process using the console

To import the orders.csv, run:
`DisbursementsApi.Orders.insert_orders_from_csv(Path.expand([PATH_OF_ORDERS_CSV]))`

To import the merchants.csv, run
`DisbursementsApi.Merchants.insert_orders_from_csv(Path.expand([PATH_OF_MERCHANTS_CSV]))`

To manually run the disbursement process, run
`DisbursementsApi.Disbursement.today_disbursements()` - but, as I mentioned, this process will run one time every 24 hours

## To test
There's only few test cases implemented
To run it you should do
`MIX_ENV=test mix test`

## My choices, assumption and why I took some directions
Despite working with Elixir for the last year and a half, I had never built a project from scratch. I thought this would be a great opportunity since I have enjoyed working with this technology.
The process of setting up the project from scratch was quite laborious, a little more than I expected to be honest. And that's why I left some improvements and processes out - even though they were part of what was required by the statement

Step by step:
1. About csv files: My idea was to automate this import process. Before running the disbursement process, check if you have a new CSV for orders or merchants and update the database
2. About process scheduling: My idea was to create a worker that would be called every X amount of time and execute the routine. Although the statement specifies the time that the result needs to be ready, I did not consider this in my solution.
3. Information processing: I would like to delve deeper into the business rules to create a more interesting database. As well as working more on the processing itself including the issue of the minimum charge amount. I tried to start something but, again, due to the time invested in the exercise I didn't complete it.
4. Tests: The testing part was quite poor. I needed to add many other scenarios to ensure that all business rules were implemented and working perfectly.

The end result may not be what I would like, but I found the process very interesting :)



