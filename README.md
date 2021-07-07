#Cyclone Solutions

Cyclone Solutions are world’s leading event management organisation. With the increasing needs of customers and to balance the employee satisfaction, the business has 
decided to automate some of the exisitng processes which are performed manually by there executives using Salesforce.

#Traditional Widget Management Process

The Widget Executives at Cyclone Solutions are responsible to record the new widgets that were added to the inventory. These widget values are required to be verified, such as validate if the brackets are balanced. 
For ex: Fruites({apple},{banana},{mango})
This is a valid value that is added to the widget list.
Consider another scenario : Fruites(apple},mango}
This is not a valid widget value and hence, needs to be corrected and added to the list.
This validation is a manual process and is time consuming as the executive has to validate every single nesting, now if the values are too long, it is very prone to human errors. This could lead to failure in data processing and hence, business loss.

#Solution Approach :
1.	Create a UI component in Salesforce which will be used by the Widget Executives and the Widget Masters to create new Widget records.
2.	This UI component will be able to validate the values entered by the user and display appropriate messages as per the results.
3.	Schedule a hourly batch class to automate the validation of new widget records and mark them as valid or invalid.
4.	To notify the Widget Executives and Widget Masters, an email will be sent which will contain list of invalid widget records, so that the users can visit the records and enter a valid value.
5.	Automate the Deployment & Testing using CI/CD via Gitlab and Salesforce DX. Create a .yml script to establish a connection. 
a.	Connect your Salesforce org and gitlab using single sign on.
b.	Create repositories in the Gitlab as per the orgs available. For example – Cyclone Solutions have Developer Sandbox, Full – Copy (QA Sandbox (Client - UAT)),  Production. 
c.	Execute the .yml Script
d.	When trying to deploy code we need to create package.xml for the components that are needed to be deployed, the rest git function is the same where we maintain the versioning.
e.	We need to create a pull request and specify the source and destination deployment branches/orgs..
f.	Once the processes like code review, functional review is done, we can use the pipelines to deploy code from one org to another.
g.	All the jobs are visible under pipelines, it validates and deploys code.

#Considerations :
1.	The Widget Masters can save the invalid records as well and proceed with these records later.
2.	For Widget Executives, it is mandatory to save the valid widget Records.
3.	The Widget Masters and Executives can edit their respective records, once they have created it.
