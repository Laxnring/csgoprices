# csgoprices

A small historical Counter-Strike:Global Offensive item price tracker. It sources price data directly from the Steam Market, obtaining daily data for the existence period of said item. 

It is composed by a Python script that sources item information (the so-called hash-name) from bitskins.com, using its api. For that, an API key first has to be acquired and changed directly in the code. Check out https://bitskins.com/api for more information.
This information is then used to call the steam market api, which requires the user to have a Steam Account. To use the Market API, one has to provide the code with the steamLoginSecure cookie related to the user's account. Using this cookie, the script queries the Steam Market API every 3 seconds, to avoid triggering the Steam scraping protection. (We can't confirm that lower values may trigger this protection, but we are sure 3 seconds for every call is enough.) The results are saved to a SQlite database called "steam.db", so be sure to have the sqlite package installed using pip.
We included an R app that currently allows the user to visualize the price evolution, while also making a prediction on the long-term evolution of the item price. This is currently under heavy development, with more features to be added in the future. 
The main goal of this project is to identify trends in the item price evolution to allow for a more intelligent investment strategy.
