---
layout: post
title: "How I Became a Bitcoin Trader"
date: "2017-12-31"
categories: 
  - "cryptocurrency"
tags: 
  - "bitcoin"
  - "blade-runner"
  - "bot"
  - "cryptotrader"
  - "gdax"
  - "trading"
---

![bitcoin-2007769_1920](images/bitcoin-2007769_1920.jpg)

## Running a trading bot for fun and profit

Bitcoin and cryptocurrencies has been a wild ride this fall. After observing the phenomenon from the sidelines for quite some time, I did as many others and bought some BTC with the intention to hold for a long time. Seeing the exchange rate go up every week was fun! However, an idea started to form. The Bitcoin market has very high volatility and is easily outpacing the stock markets by a lot. It must be possible to make a decent profit just by buying low and selling high. This should be a perfect task for a bot.

## Enter CryptoTrader

After first considering to build a bot using Bitcoin exchange APIs directly, a friend mentioned there are purpose-built platforms and frameworks for this already. [CryptoTrader.org](https://cryptotrader.org/) is a big platform for trading bots, offering both the tools to build your own bots and a market for renting bots others have written. Best of all, the site takes care of running the bots 24/7 and all you need to get started is an API key from your favorite exchange.

## Getting started

I use [Coinbase](https://www.coinbase.com/) to buy and hold, so using their [GDAX](https://www.gdax.com/) exchange was the quickest way to get started. You get trading accounts at GDAX by completing a short signup process, which contains an additional ID verification complementing the one you had to go through when signing up for Coinbase. Transferring funds between Coinbase and GDAX accounts is instant and free. The main downside to GDAX is that they have a limited number of currency pairs compared to other exchanges. The pairs are based on Bitcoin, Ethereum and Litecoin only. That's not a big problem when getting started in this field, but as you get more experienced you'll want to explore currency pairs offered by other exchanges too. CryptoTrader supports a long list of exchanges and currency pairs.

When considering to use CryptoTrader it is highly recommended to backtest bots on historical data. Although writing my own bot is a long-term goal, I chose to browse the bot marketplace for a bot to rent to get started. CryptoTrader has a slightly strange convention for displaying bot popularity. The most popular bot has a "100%" beside it and other bots have lower percentages, instead of using a simple count of the number of running instances. For simplicity I chose to focus my initial testing on the most popular bot, [Blade Runner](https://cryptotrader.org/strategies/YArPks8njZKipEJs9).

Blade Runner is built on a compelling "always sell higher" logic. The bot automatically detects the market conditions as one of rising, falling or sideways market. Based on current price it calculates the price levels where it wants to buy and sell, and executes orders based on that. Whenever it buys, it immediately registers a sell order at the exchange at a price point which is about 3% higher than the buy price (a "limit sell" order, i.e. an order with a requested price for the sale to happen). The sell order remains in the order book of the exchange until that price point is reached and the order is executed by the exchange. Whenever one of the limit sell orders are traded at the exchange, the bot has made a profit. This is the "always sell higher" logic, ensuring a profit at every sell.

There is one catch with this logic: The sell price has to be reached for the profit to be realized. If the bot buys and the market starts falling for a long time, the sell orders will just stay in the exchange order book. The bot does not seem to adjust the sell orders to the new market conditions, so you simply have to wait for the market to rise again to the predefined sell prices even though that might take days (or weeks). This means you need a medium- to long-term horizon for your trading bot and cannot expect phenomenal returns in hours. It is best to view the trading bot as a way of consistently increasing the amount of cryptocurrency you hold.

## Testing, testing, testing

All the getting started guides for trading bots stress that it's important to backtest. This means running a lot of simulations on historical data to get to know the behavior of the bot, tweak the settings and evaluate if it's able to give consistent profits. So I started backtesting Blade Runner on the BTC-USD currency pair. I ran multiple simulations of different time periods, and in at least two of them there was a significant profit. Eager to get started for real, I purchased the entry plan of CryptoTrader and rented the bot for three months. Buying access and renting the bot was a smooth process where the CryptoTrader platform generated invoices in BTC and I just had to send the BTC from my wallet to the address in the invoice.

With access, I continued to backtest the bot on BTC-USD. And then I realized, to my dismay, that I was unable to find a combination of bot settings that made the bot give positive returns and at the same time beat the "B&H" strategy. B&H is Buy & Hold, which all backtests and live bot instances are automatically compared to. The B&H percentage is the percentage of profit or loss you would get by just buying at the start of the time period and holding the assets until the end of the time period. When backtesting on BTC-USD on the long time period of rising BTC rates this fall, the B&H percentages were usually in the double digit profits. The bot was unable to match that. However, for certain short time periods of corrections in the BTC rates against USD the bot was giving net profits while B&H was negative.

Based on these findings I concluded that the Blade Runner bot performs best in a sideways market. Reviewing the various currency pairs on GDAX, I found that ETH-BTC is usually a sideways market and decided to go with that pair. By being crypto-crypto this pair has additional advantages as I see it. First, this means my assets are in cryptocurrency all the time. This conforms nicely with my initial goal of buying and holding cryptocurrency. Second, I would not consider following a B&H strategy for the ETH-BTC pair (buying ETH at the start and calculating profits based on the ETH-BTC rate). So I can safely ignore any B&H percentages the bot reports as irrelevant for my case. Instead, the goal is to get net profits so that the bot contributes to an increase in my cryptocurrency assets. Any increase is a win, although the first goal is to earn back what I paid for access to CryptoTrader and the Blade Runner bot.

## Running the bot

\[caption id="attachment\_1058" align="alignnone" width="1131"\]![Blade Runner bot running](images/blade-runner-bot-running.png) Screenshot of live bot instance running on the CryptoTrader platform\[/caption\]

The bot has a set of parameters for tuning the behavior, along with six main modes of operation: Optimal, Automatic, Rising, Falling, Sideways and Very Low Capital. I started out with a small amount of BTC for trading and chose the Very Low Capital mode. In all other modes the bot uses a varying percentage of the total funds when placing each order. In the Very Low Capital setting this percentage is always 50%. The main reason for this is to ensure that the amount in each order is enough to avoid being rejected as too small by the exchange. This setting did however result in very few trades per day and low profits. So I quickly switched to Optimal mode instead.

Optimal mode automatically tunes the various parameters based on the market conditions. One example is that in a rising market the bot increases the amount it buys compared to a sideways or falling market. This is done to buy bigger amounts as early as possible to capture more of the rising trend.

There is one important setting to tweak in Optimal mode: "Activation of the above Percent Price Fall or Rise". By default it is set to "Only for Price Fall", but I got much better results by choosing "For Both Cases". The default setting only buys when the price is falling below a calculated threshold of about 3% below the price of the last buy or sell order. To capture rising trends it's important to buy when the price is going up too (betting on the price to increase further).

## Adjusting the funds

When I found the settings that worked best and produced a steady profit, I increased the amount of BTC the bot could trade with. Before depositing funds to the exchange account the bot is using, it is important to activate the "Reset button" in the bot settings (you can keep the bot running). Deposit funds, then wait for a minute or two before you deactivate the "Reset button" in bot settings. This way your deposit won't interfere with how the bot calculates profit.

There are other ways of manual interference too, for example a "Pause button" to stop the bot from making any new buy orders for a period of time. You can also press Buy or Sell buttons to instruct the bot to place orders. But that will influence the bot profits as the price point is probably not optimal.

It's also worth mentioning that you can stop the bot and start it again later. When the bot stops all open sell orders are cancelled, leaving the funds in the trading account in the state it was when the bot stopped (some in ETH and some in BTC, in this case). Before starting the bot again you need to make sure all funds are in the "base currency", meaning the last one in the trading pair (for ETH-BTC that would be BTC).

One situation you need to be on the lookout for is the bot stopping due to the total amount of funds exceeding the CryptoTrader plan limit. The various plans you can choose from, include limits in the amount of funds the bot can use for trading. The limits are measured in USD. I started with the Basic plan, and when the funds in the trading account exceeded the limit, the bot was stopped. There was no email alert about this, so I discovered it when checking in on the bot the next day. I paid for an upgrade to the Regular plan and started up the bot again. This means you cannot just start the bot and forget about it, as it might stop at any time without notice. All it takes is for one of the cryptocurrencies in your trading account to quickly rise in value compared to USD.

## Preliminary results

The bot has managed to generate enough profits in three weeks to cover the amount paid for three months of access to CryptoTrader and the bot itself. This was my initial goal. I'll be running the bot for the remaining time period it has been rented for to generate net profits. But I'm sure it is possible to do better. There are lots of other promising bots in the CryptoTrader strategy marketplace, so I'll spend time backtesting other bots and other cryptocurrency trade pairs to find even better combinations. I might even start writing my own bot.

This has been a very exciting experiment and I've learned a lot about cryptocurrencies, trading, signals and bots. Generating a net profit is also nice, even though it's not very big. The biggest advantage is all the new knowledge.

Remember that the information in this blog post should not be relied upon as advice or construed as providing recommendations of any kind. Any trading activity is inherently risky and it's important to keep in mind that all money used for trading could get lost.

Did you find this useful? Consider donating some BTC to 13sTihkkJtP8UjuWFgFpEiFuiheCb9fQNE if you want.

~ Arne ~
