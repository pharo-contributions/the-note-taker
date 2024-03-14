"
To instantiate a `Collection` of notes (`NTNoteObject`) evaluate:

```smalltalk
NTTestResource new objectNotes.
```

To access the same notes as parsed by STON:

```smalltalk
NTTestResource new stonNotes
```
"
Class {
	#name : 'NTTestResource',
	#superclass : 'TestResource',
	#category : 'TheNoteTaker-Tests-Support-Resources',
	#package : 'TheNoteTaker-Tests',
	#tag : 'Support-Resources'
}

{ #category : 'accessing' }
NTTestResource >> jsonNotes [

	^ '[{
  "title": "Daily To-Do List",
  "contents": "Complete daily tasks such as brushing teeth, eating breakfast, and checking emails.",
  "tags": [ { "tagName": "daily" }, { "tagName": "tasks" } ],
  "createdAt": "2024-03-12T08:00:00Z"
},
{
  "title": "Exercise Plan",
  "contents": "Performed 30 minutes of cardio and 20 minutes of strength training.",
  "tags": [ { "tagName": "exercise" }, { "tagName": "cardio" }, { "tagName": "strength" }],
  "createdAt": "2024-03-13T09:00:00Z"
},
{
  "title": "Grocery List",
  "contents": "Buy fruits, vegetables, and snacks.",
  "tags": [ { "tagName": "grocery" }],
  "createdAt": "2024-03-14T16:00:00Z"
},
{
  "title": "Weekly Schedule",
  "contents": "Scheduled work hours, appointments, and leisure activities.",
  "tags": [ { "tagName": "weekly" }, { "tagName": "schedule" } ],
  "createdAt": "2024-03-15T10:00:00Z"
},
{
  "title": "Shopping Planner",
  "contents": "Researched and planned purchases for upcoming trip.",
  "tags": [ { "tagName": "shopping" }, { "tagName": "travel" } ],
  "createdAt": "2024-03-17T13:00:00Z"
},
{
  "title": "Weekly Progress Report",
  "contents": "This week, I completed the first draft of a new project proposal. I also met with several clients to discuss
their needs and expectations for upcoming projects.",
  "tags": [ { "tagName": "weekly" }, { "tagName": "progress" }],
  "createdAt": "2024-03-20T16:00:00Z"
},
{
  "title": "Cooking Planner",
  "contents": "This weekend, I plan to make a vegetable stir-fry with tofu and brown rice. I''''ll also bake a chocolate cake
  for dessert.",
  "tags": [ { "tagName": "cooking" }, { "tagName": "planner" } ],
  "createdAt": "2024-03-19T12:00:00Z"
  },
{
  "title": "Fitness Goals",
  "contents": "My fitness goals for this month are to run 5K every weekend and complete a full body workout 3 times a week.
Here''''s my workout plan for the next week:\n- Monday: Cardio (running or cycling) and upper body weights\n- Tuesday: Lower
body weights and abs\n- Wednesday: Yoga and stretching\n- Thursday: Full body workout\n- Friday: Rest day",
  "tags": [ { "tagName": "fitness" }, { "tagName": "goals" } ],
  "createdAt": "2024-03-25T11:00:00Z"
},
{
  "title": "Weekly Review",
  "contents": "This week, I reviewed my progress on various projects and made adjustments to my schedule accordingly.
 Here''''s a summary of what I accomplished:\n- Completed project proposal draft\n- Met with several clients for project
 consultations\n- Attended a web development workshop\n- Reviewed and updated my personal development plan",
  "tags": [ { "tagName": "weekly" }, { "tagName": "review" }],
  "createdAt": "2024-03-26T15:00:00Z"
},
{
  "title": "Travel Planner",
  "contents": "I''''m planning a trip to Europe next month. Here are some of the places I want to visit:\n- Paris, France\n-
Rome, Italy\n- Barcelona, Spain\n- Berlin, Germany\n- Amsterdam, Netherlands",
  "tags": [ { "tagName": "travel" }, { "tagName": "planner" } ],
  "createdAt": "2024-03-31T19:00:00Z"
},
{
  "title": "Monthly Recap",
  "contents": "March was a productive month for me. I accomplished a lot of my goals and made progress on several projects.
Here is a recap of what I achieved:\n- Completed project proposal\n- Met with clients to discuss their needs\n- Attended a web development workshop\n- Reviewed my personal development plan",
  "tags": [ { "tagName": "monthly" }, { "tagName": "recap" }],
  "createdAt": "2024-04-01T15:00:00Z"
}]
'
]

{ #category : 'accessing' }
NTTestResource >> objectNotes [
	"Answer a <Collection> of <NTNoteObject> to use in tests and examples"

	^ (NeoJSONReader on: self jsonNotes readStream) nextListAs: NTNoteObject.
]

{ #category : 'accessing' }
NTTestResource >> stonNotes [
	"Answer a <String> in STON format containing mock notes"

	^ STON toStringPretty: self objectNotes
]
