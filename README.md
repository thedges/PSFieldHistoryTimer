# PSFieldHistoryTimer
THIS SOFTWARE IS COVERED BY [THIS DISCLAIMER](https://raw.githubusercontent.com/thedges/Disclaimer/master/disclaimer.txt).

Simple component to show time a field was in a given state based on field history.

This is simple component to show the amount of time that a field's value has been in a specific state. The component only shows one field value and typically usage is for picklist fields. Here is sample image of component:

![alt text](https://github.com/thedges/PSFieldHistoryTimer/blob/main/PSFieldHistoryTimer.png "PSFieldHistoryTimer")

Another sample here:

![alt text](https://github.com/thedges/PSFieldHistoryTimer/blob/main/PSFieldHistoryTimer2.png "PSFieldHistoryTimerConfig2")

## Component Configuration Parameters

| Parameter  | Type | Definition |
| ------------- | -------------| ------------- |
| Header SLDS Icon | Text | The value for the component header icon at top of component. Use string format for [SLDS icons](http://www.lightningdesignsystem.com/icons/). Format is <section>:<icon_name>. For example the "approval" icon in the "Standard Icons" section would have value of "standard:approval".  |
| Header Title | Text | The value for the header title at top of component. |
| Field API Name| Text | The API field name of the field to show timer history. |
| Hours to Escalate | Number | The number of hours that field will be in state before it changes timer to red color. |
| Completed State | Text | The field value that indicates a "completed" state/value. Indicator will say "Complete" in green color. |

Sample configuration like the following:

![alt text](https://github.com/thedges/PSFieldHistoryTimer/blob/main/PSFieldHistoryTimerConfig.png "PSFieldHistoryTimerConfig")


# Installation Instructions

<b>Here are steps to use this component:</b>
  
1. Install the component per the **Deploy to Salesforce** button below
2. Make sure to setup Field History for the field you want to use this component for.
2. Assign the **PSFieldHistoryTimer** permission set to whatever user needs access to this component.
4. Drag the **psFieldHistoryTimer** component on to page and configure per the above parameters. That's it!
  
<a href="https://githubsfdeploy.herokuapp.com?owner=thedges&repo=PSFieldHistoryTimer&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>
