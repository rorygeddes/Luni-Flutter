Luni combines Plaid’s transaction data, AI classification, and a guided onboarding survey to create a self-learning budgeting system. The user journey flows through four major stages:
Onboarding & Profile Setup


Values & Income/Expense Survey


Bank Connection via Plaid


AI-Assisted Transaction Allocation and Splitting


1. Onboarding & Profile Setup
App Launch
The user lands on the Sign Up / Sign In screen.
Creates username, password, and uploads a profile image.
Each user receives a Public ID for transfers (like Venmo lookup).


Basic Info Questions
Step-by-step (one question per screen) UX flow:
Name, School, City, Age


Purpose Selection
User selects 3 main reasons for using Luni:
Split expenses with roommates
Save for a trip
Afford tuition
Have fun responsibly
Know my net worth
Understand spending habits
Identify “money bleeds”


Profile Data Storage
Data stored in profiles table with survey responses, habits, and purpose tags.
AI later uses this to weight nudges, tone, and category budgets.

💰 2. Income, Work & Expense Survey
Employment & Income Questions
“Do you have a part-time job?”
“How many hours per week?” × “Pay per hour” → monthly income estimate.
Optional: secondary job or side hustle → adds to total income per cycle.


Support & Transfers
“Do you receive help from family/friends?”
“Do you take money from savings or investments regularly?”


Expense Estimation
“How much is rent per month?”
“How much do you spend on groceries per trip?”
“How often do you buy groceries?”
The system computes monthly averages and expense cycles.
Spending Pattern Recognition & Favourites
The user selects common merchants (logos shown): fast food, subscriptions, clothing, etc.
Inputs how often they go each month, week
Option to enter favourites manually for future classification cues.
This allows the system to understand where the user likes spending, and it can identify the bleeding
🗂️ 3. Account Setup & Category Mapping
The whole goal of the accounts is to categorize the general ones so the user can be aware of where their money is going. Normally, the accounts that students tend to lose track of are the ones that are the fun, not the essential things. In the setup screen, each of these parent categories are shown with some sub categories highlighted. This means that they are selected in the onboarding process and will show up when you login to the app. In this setup stage, you can deselect some icons, or add in others, or add in custom.

Typical Expense Accounts 


Living essentials: Rent, Wifi, Utilities, Phone
Education: Tuition, Supplies, Books
Food: Groceries, lunches / coffee out, Restaurants / dinner
Transportation: Bus Pass, Gas, Rideshare
Healthcare: Gym, Medication, Haircuts, Toiletries, 

Accounts to watch
Entertainment: Events, Night out, Shoppings, Substances, Subscriptions
Vacation: Listed when you create a new trip; Ex: Europe, Christmas Skiing, Travel Home…
Income Accounts: Job Income, family support, Savings / investments gain, Bonus

Personalized Additions
Survey data creates optional sub-accounts (eg: “Concert Tickets”, starbucks, zara, etc).
Users can edit these once per parent category.


UI Flow
Each category presented full-screen → user reviews → hits “Submit.”
Allows “Back” navigation but only processes on submit for AI consistency.



🏦 4. Bank Connection via Plaid and Categorization flow

This is the most important part of the app. It will work by being an automated and live system so the user will never get behind. The one thing the user needs to do is to categorize their spending regularly, like every couple days for it to work.
First Connection Trigger
On Home Screen, users see: “Connect Bank Accounts (Premium Feature).”
Plaid Setup Flow
Opens Plaid’s “Connect My Bank” interface.
User authenticates and grants read-only access.


Data Import
Plaid’s api key automatically Pulls the previous 90 days worth of transactions
The accounts the user selected in the frontend plaid link will fill up the track screen and will be organized so the user can swipe left and right to navigate between them. These accounts will have the current balance at the top. Under them, it will have the accounts that were retrieved from the api key.
However, these transactions will be uncategorized, the only info that is in there is the raw data it pulls from the bank transactions.
The only way to see items be categorized is for the user to accept the categorization from the ai, which will be in the transaction queue screen. 
That transaction queue screen is linked to each of the transactions in all bank accounts, but is then shown up as auto ai categorized for the user to view it, and then accept the screen to add a confirm layer and human decision element so they also understand to see if the info is correct.


AI Categorization Prep
AI starts off with the basic budgeting knowledge, and the answers the user gave in the survey and setup stage of the system. It checks the description from the bank given, and cleans it up. In the transaction queue screen, it will make the description look nicer by cleaning up any extra bank character used. For example: CinePLEX***6777, will turn into Cineplex. Or E-TRANS__667**7, will turn into e-transfer in or out depending on the sign of the amount. 
AI will analyze any info it may have from the raw bank info, and the database of budgeting strategies, and info our system has. 
Once it has a better description, the next part the ai will categorize is the category. It will take the description it cleaned up, and will then access the system again and categorize that by matching it with the most likely possibility from the database, which will have many examples. 
It will create categorization for the parent account (living, food, entertainment, etc), and then will assign it to a subcategory (rent, groceries, night out). 
It will also check the sign to see if it’s an income or expense (positive = income, negative = expense). 
Every transaction and ai categorization is logged in the memory, for the ai system to remember common transactions, and any possible edit the users fixes. For example if they categorize a store “Big General” as a restaurant, but it’s actually a grocery store, the user then corrects the ai’s category. The ai will remember their categorization, and also the users fix to groceries, and next time it says Big General, it will assign it to groceries instead.
After the fields, Description, Category, Sub category, type (income or expense), are filled out and completed, there is another box the user can check that is called Split. If the user checks this box, after the user submits the screen, that transaction will be assigned to the split screen queue, where it will do a similar review of the accounts that are placed there from this queue, and assign a splitter for the transaction.
Once the user checks out all fields, updates any wrong categorization, assigns the split features, and are happy with the accounts, they may then select the submit button at the bottom of the screen which will then accept the additional info to each transaction and categorize them. Once they are categorized, they are removed from the queue, and are then shown up with the categorized elements in the accounts screen in the track screen. In each account, the transactions remain there, however the newly categorized transactions will show up with a nicer gold colour border around it, signaling it is now complete. Before, the transactions were white and black, with no extra categories.
The queue then brings up the next screen and the user repeats. 
The transaction queue has a limit of 5 transactions per screen to allow the user to only have 5 transactions to look at at a time, and is better for saving them as you go, and limits the risk of losing progress.
After all the transactions are categorized, the transactions api from plaid will listen and pick up the new transactions that follow and they will be updated in the account screen as uncategorized, and then sent to the queue to be updated. This is the system and it will be repeated.
 5. Splitting Queue

This screen will be for the transactions that were assigned here from the main transaction queue. This will have more specific features and selections as it gets more complicated. Here is the workflow for it:
The transaction will appear in the queue with the same basic info: The date, ai_description (or manually modified by the user), and the amount. Under it, will be a dropdown for the group, and then the person. The group button will show you all the groups you are currently in. These could be: Family, roommates, friendgroup, girlfriend, etc. This is basically a filter method, as once you assign the group, the person will update to match the group. The person dropdown will only allow the values to be shown that are within the group. For example: If dad is in my family, I select the family group, and then I can select dad as the person. 
If I want to cut to the chase and select a person quickly, I can just hit the person dropdown, and search for a person in my contacts. The group is just a filtering, but also a public private indicator. If the user selects a group, there is an option to select "make transaction visible to group”, and this transaction will be posted to the group chat of the group which is a feature built into the app.
There is also flexibility with the person, you can add multiple people to split a transaction with.
Same thing with the all transactions queue screen, the split queue will only allow 5 transactions to be processed at a time.
Once the user hits the submit button at the bottom of the screen, the data is then passed into the split screen and its functionality. In this screen, you can see all of your groups you are in. (I’ll get to the functionality later)

📊 5. Home & Track Screens
Home Screen
Displays:
Present Value (add up all accounts from plaid, (subtract credit))
Daily Report, which shows the user important information of their day, the amount they owe people, the amount people owe them. Warns them if anything is happening. Give a sentence or two about a positive and something to work on.
“Connect Bank” button, if unlinked
Quick Accounts view. The total monthly spending breakdown of each larger category, and the same with the sub categories.


Track Screen
Organized by:
There is an all accounts screen that combines all accounts transactions by date, and at the top shows the net present value. This helps the user see where they are, and are also able to go between accounts to see where it came from. If you click on a transaction, it will take it to the account that it’s in, at the exact location, and then the bottom part of it will extend to see more key information.
The separate accounts is a more detailed view of the accounts breakdown in the home. It has a list of all categorized and uncategorized accounts from the entries from plaid, and the categorized the user gave. There are also filters at the top where the user can filter by monthly, past 3 months, category, split with… any details.
Parent Category → Sub-Accounts Real Accounts (Plaid-linked)

⚙️ 10. Technical Notes
Layer
Responsibility
Frontend (Flutter)
UI screens: Sign Up, Survey, Track, Queue, Split
Backend (Flask or Supabase)
Auth, storage, Plaid webhooks
AI Layer
Categorization, normalization, confidence scoring
Database
profiles, accounts, transactions, splits, rules
Plaid API
Bank connection + live transaction sync


🚀 11. Core Workflow Summary (End-to-End)
User signs up → completes profile & survey


AI builds default + personalized categories


User connects bank via Plaid


Plaid imports 90-day transactions


AI processes and normalizes data


User confirms/corrects transactions


Confirmed transactions update accounts, now categorized


Optional: Split shared expenses


AI learns from user behavior → reduces manual work each cycle



