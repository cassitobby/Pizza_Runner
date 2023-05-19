# Pizza_Runner
This is the week one of the 8 Week SQL Challenge by Danny Ma. [Click here to view all material and respected credit]([url](https://8weeksqlchallenge.com/case-study-2/))

![image](https://github.com/cassitobby/Pizza_Runner/assets/128924056/1d1e083a-da3a-4921-8340-5a7f31b2d965)

# Introduction
Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

# Problem Statement
Danny has created an entity relationship diagram (ERD) for his database design in the Pizza Runner challenge. However, he needs additional support to clean and refine his data, as well as perform basic calculations. This will enable him to make more informed decisions regarding the direction of his runners and optimize the operations of Pizza Runner.

# Entity Relationship Diagram. 
![image](https://github.com/cassitobby/Pizza_Runner/assets/128924056/470a6797-d45a-4193-ad88-144549fce882)

# Skill Demostrated
- Data Cleaning: Skilled in cleaning and refining data to ensure accuracy and consistency.
- SQL Querying: Proficient in writing SQL queries to retrieve and analyze data from databases.
- Data Analysis: Skilled in deriving meaningful insights from data through pattern identification and trend analysis.
- Database Schema Understanding: Familiar with understanding and navigating complex database schemas, including primary and foreign key relationships.
- Problem-Solving: Capable of solving business problems by translating requirements into SQL queries and finding efficient solutions.
- Data Manipulation: Experienced in manipulating and transforming data using SQL functions and operators.
- Basic Calculations: Able to perform calculations and apply mathematical operations to analyze and derive insights from data.

# Case Study
- [Data Cleaning]([url](https://github.com/cassitobby/Pizza_Runner/blob/main/Solution/Data_cleaning.sql))
- [Part A. Pizza Metrics]([url](https://github.com/cassitobby/Pizza_Runner/blob/main/Solution/A.%20Pizza%20Metrics.sql))
- [Part B. Runner and Customer Experience]([url](https://github.com/cassitobby/Pizza_Runner/blob/main/Solution/B.%20Runner%20and%20Customer%20Experience.sql))
- [Part C. Ingredient Optimisation]([url](https://github.com/cassitobby/Pizza_Runner/blob/main/Solution/C.%20Ingredient%20Optimisation.sql))
- [Part D. Pricing and Ratings]([url](https://github.com/cassitobby/Pizza_Runner/blob/918ec94d15195ada6922d7d8f59cb46b1594bdc4/Solution/D.%20Pricing%20and%20Ratings.sql))
- [Part E - Insight and Recommendation]([url](https://github.com/cassitobby/Pizza_Runner/blob/main/Insight%20%26%20Recommendation.sql))

# Insight
1. Total of 14 orders were placed. These orders originated from 10 distinct customers.
2. Runner 1 has the highest number of successful deliveries, with a total of 4 deliveries. This indicates that Runner 1 
   has been the most active and efficient in completing successful deliveries among all 3 runners in the dataset.
3. A total of 9 MeatLovers pizzas were delivered, while 3 Vegetarian pizzas were delivered. This showcases a higher
   demand for the Meat Lover pizza compared to the Vegetarian option
4. only one delivered pizza had both extra toppings and exclusions specified. This suggests that most customers either 
   opted for additional toppings or requested certain ingredients to be excluded, but not both simultaneously. It could 
   be inferred that customers typically choose one customization option over the other, rather than combining them in a 
   single order.
5. Most orders were made Saturdays and Wednesdays. The least order was on Fridays
6. Week one has the highest number of runner sign-ups, with a total of 2 runners joining the platform. 
7. There is a positive relationship between avg delivery time and pizza quantity. This implies that as
   the number of pizzas in an order increases, the average delivery time also tends to increase.
8. Customer 105 has the highest average distance traveled compared to other customers. This indicates that, 
   on average, Customer 105's delivery locations are situated farther away from the pizza store compared to
   the average distances traveled by other customers.
9. Runner 2 is the fastest rider
10. Runner 1 has the highest delivery rate
11. Bacon is the most commonly added extra while Cheese is the most common exclusion
12. Mushrooms & Bacon are the most used Ingredient
13. The restaurant generated a total revenue of $138.
14. Pizza runner has a total of $94.44 after payment has been made to riders

# Recommendation 
1. Optimize delivery routes: Since there is a positive relationship between the average delivery time and pizza quantity,
   it is essential to optimize delivery routes to minimize delivery times. Implementing efficient route planning can help
   reduce overall delivery times.

2. Offer promotions on Fridays: As the data indicates that Fridays have the lowest number of orders, consider offering 
   promotions or discounts specifically targeted for Fridays to incentivize customers and boost order volumes on that day.

3. Analyze customer preferences: Further analyze customer preferences for Meat Lover and Vegetarian pizzas to understand 
   the demand patterns better. This can help in adjusting the inventory and ingredients accordingly to meet customer 
   expectations and maximize customer satisfaction.

4. Provide incentives for runners: Acknowledge and reward the top-performing runner, such as Runner 1, who has the highest
   number of successful deliveries. This can help motivate and retain efficient runners while encouraging healthy 
   competition among the delivery team.

5. Explore marketing opportunities: Given that most orders occur on Saturdays and Wednesdays, consider allocating marketing
   efforts and resources towards these peak days. This can involve targeted advertising campaigns, promotions, or 
   partnerships to further drive customer engagement and increase order volumes.


