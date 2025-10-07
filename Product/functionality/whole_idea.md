This document is my ideas of what I want it to be, unformatted and just raw data:

I want you to look at my files and understand this info below, and create a better prompt / md file to be given to cursor ai. I want to add to my flutter project with this information to make it become functional.

I want you to understand my entire idea and read my information on how this app works. I want you to create an overview.md file. I want this file to go over the functionality of how plaid and ai interact together to create a perfect onboarding and functional experience for the user. This is the main idea of how the system should work so use this as the main chunk of info for this md file. I want the user to open up the app and it opens to a sign up screen, or sign in screen. I want this screen to ask the user whats their name, create a username and password. I want them to be able to easily upload a profile image of themselves for others to see. this acts as their online profile, this is like a version of how venmo works. The idea is that I'm able to look up someone or have a public id out there where someone can look up my info to e-transfer them. After the user enters their profile info, it brings them to a screen asking them their personal info. This screen is a very simple ui, it only asks one question at a time. It goes over what school, what city, what age you are. THen it goes over personal questions and asks spending patterns:
It will ask for why the user is using the app: (selects the 3 that most apply)
- I want to split my expenses better with roommates
- I want to be able to save for a trip
- Afford tuition and school fees
- Be able to have fun without worrying where my money is going
- know my net worth at all times
- be more aware of my spending habbits at certain locations
- where do I bleed money the most?
Then it will ask some more important questions:
- do you have a part time job?
- how many hours per week? pay per hour? (multiplies these together, then multiplies it by amount of weeks in the month for each cycle, includes decimals)
- Do you have another job or side hustle? if job repeats question.
- If side hustle, how much extra do you make per cycle estimate
- Do you get any help from your parents, family members, friends?
- If yes, how much per cycle
- Do you take out any money from savings regularily in each of these cycles?
- The same as above with investing?
Expenses:
- How much is your rent per month? (divides by required cycle)
- How much do you spend on groceries when you go to the store? (easier for people to remember the number when they go, not every week)
- How often do you get groceries? (calculates time spent, relative to the cycle time to figure out the cycle amount)
-
Each cycle = one “container” where income, expected expenses, and actual spend flow in/out.
Will ask what smaller expenses places you regularily spend your money at
- will show a bunch of logos of common restaurants, fast food, subscriptions, etc that the user pays for monthly
- a spot for inputting favourite restaurant, fast food, clothing store, etc
this data will all be saved to their profile in the backend to evaluate and help the ai understand their spending habbits better.
This will then create a system that evaluates the most common accounts they would typically use and put their accounts together. There will already be specific accounts setup that the user can't change like:
### Housing & Utilities
- Rent
- Utilities
- Internet
- Furniture/essentials
### Food & Drink
- Groceries
- Coffee Shop
- Nicer Meals out
- Snacks & Fast food
### Transportation
- Public transit pass
- Gas
- Car insurance & maintenance
- Rideshare
- Bike/scooter
### Education
- Tuition & fees
- Textbooks
- Supplies
### Personal & Social
- Clothing
- Entertainment
- Nights out
- Sports & Hobbies
- Alcohol / substances
- Subscriptions
### Health & Wellness
- Health insurance / school plan
- Medication / pharmacy
- Fitness / Gym
- Haircuts
### Savings & Debt
- Emergency fund
- Credit card payments
- Student loans
### Students Income
- Employment
- Family Support
- Loans & Aid
- Other/Bonus
The surveys can then create more personal sub accounts that the user could care more about and they can update the default accounts. The screen will go parent account by parent account for each screen so it will be easier for the user to see visually. They will accept the screen and move on to the next for simplicity, THe user can always hit go back and edit their response, but will have to hit submit for the larger areas for the ai to process the information. 
Then this will take them to the home screen that we’ve already made with all the app views. There will be no data in there, except the information they gave at the start. The accounts will be in the track screen, sorted nicely by account and sub account. These are like categories, not bank accounts. They will then hit the setup bank integration once they pay for premium (future). For now, there will be a button in the home screen under dailly report that says connect bank accounts! 
Then you will proceed to a setup mode with simple full screen navigation with plaids connect my bank account interface. Once the integration is complete, the accounts will all be set up, and be filled into your track. These will be under real accounts and will go over each account by swiping left and right and it will show the balances of each account.
Under the categorization section inside the track screen, you will see all of the accounts budget amount which is taken from the data plaid api took from the last 90 days. 
In the home screen, you can then see your present value, which is all your accounts added up (subtracting credit, adding debits). 
If you click on the plus screen, it will be the spot where you allocate transactions that plaids api key picks up on, no longer using the phone for taking a picture of your expenses so remove that. It will have an items in queue view. In here, it is where the user can assign all of the past transactions. The transactions will all show up here that haven’t been allocated from plaid. They will show up in this screen like how the bank screen is in the td app, it will be a long receipt type style with good ui, but will have the date as a header, then the transactions below it. The transaction will be shown with a description, amount to its right with a green or red colour depending on the sign, then under it will be the main account (food, housing, social) and then smaller sub account (groceries, rent, drinks). If you click on any of these fields, you can edit them. THe description is taken from plaids transaction, and then processed through open ai’s api key to create a simplified version. The goal here is to get the use of it, for example: Pizza_hut_Sq223. It will be Pizza Hut. Or E-trans**5577, it will be E Transfer Out or in. If it’s one of these accounts the account will be miscellaneous expense or income that is unknown. These types of transactions come up at the initial process, but should be worked on later on and fixed by giving the ai more information. There should be a spot somewhere for the ai to have a memory or custom spending habits area the user can give it to get an understanding of their habits. I want the ai to look at the description and try to assign it to an account and sub account as well. The whole goal of the ai is to help reduce the amount of brain power for the user to allocate the accounts by thinking. It should always be going somewhere and the user has a fix, not think mindset where they see the transactions and organize it after the ai assigns it to make it more productive. On each of these transactions there is also a button for split. If the user hits split, this will go into the split queue where they must deal with that later in the other screen. After the user goes through each of the transactions they want, they will hit submit. And then these transactions will be logged in the system. Also an important note is that this screen will have a limit of 5 transactions per screen as it is much easier to input 5 at a time then 180. After uploading each time the 5 transactions, the screen will be accepted and the next transactions in the queue will appear. The user can always x out of the upload screen and go back to other screens, and the transactions that were submitted will be submitted into the system already will be saved, the transactions still unassigned will remain in this queue. The split screen will have any transactions here that the user assigned from the main queue. Here, they can select the group they want to split with (if any), or select the person from their contacts. If its for example their house, they can select their house option, and then the roommates in the house will be available in the next dropdown menu that are in the house. If you have a family group and select that, you will then only see the family members there. This transaction can then be publicly shown in the group chat, or private as well. If its private it gets sent to a private chat. This pubic and private option can be selected in the split view queue. Same as before, there will be a limit of 5 transactions per screen, and they will be submitted if the user hits the accept button. After selected they will go into your internal accounts that categorizes your sub account, which can be viewed in your track screen. Remember this is only for categorization purposes, the system already knows the transaction is in the account it was assigned to. You can also see your transactions that are categorized. IF they are uncategorized, they will remain in the queue, and will only be placed in the accounts track area when categorized and submitted. The balance won’t be affected in the main accounts though. (Make sure this system is fixed). This is at the start, but when the  user adds in a new transaction, the balance gets updated when the user adds in their categorization is done. Not sure if plaids transactions api always accounts for the current account totals so thats why I will need this system. 
After the accounts are categorized, the plaid api key will still listen for new transactions, and the new ones will be sent to the queue and will wait to be allocated by the user. 