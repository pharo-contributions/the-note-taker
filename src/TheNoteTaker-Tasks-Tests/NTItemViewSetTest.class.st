"
I test `NTItemViewSet`: the default views and the reading and writing of `views.md`.
"
Class {
	#name : 'NTItemViewSetTest',
	#superclass : 'NTTaskTestCase',
	#category : 'TheNoteTaker-Tasks-Tests-Views',
	#package : 'TheNoteTaker-Tasks-Tests',
	#tag : 'Views'
}

{ #category : 'tests' }
NTItemViewSetTest >> defaultsText [

	^ self text: '{
  "views" : [
    { "name" : "Today", "period" : "today" },
    { "name" : "This week", "period" : "week" },
    { "name" : "Monthly review", "period" : "month", "includeNoDue" : true, "groupBy" : "task" },
    { "name" : "Late", "period" : "overdue" },
    { "name" : "Waiting for others", "has" : [ "waitingOthers" ], "groupBy" : "waitingOthers" }
  ]
}
'
]

{ #category : 'tests - errors' }
NTItemViewSetTest >> should: aText failWith: aString [

	| error |
	error := [
		         NTItemViewSet fromText: aText.
		         nil ]
		         on: NTViewsFormatError
		         do: [ :e | e ].
	self assert: error isNotNil.
	self assert: error messageText equals: aString
]

{ #category : 'tests' }
NTItemViewSetTest >> testAddRemoveAndViewNamed [

	| set today |
	set := NTItemViewSet defaults.
	today := set viewNamed: 'Today'.
	set remove: today.
	self assert: (set viewNamed: 'Today') isNil.
	set add: today.
	self assert: set views last equals: today
]

{ #category : 'tests' }
NTItemViewSetTest >> testDefaultViewNames [

	self
		assert: (NTItemViewSet defaults views collect: [ :each | each name ] as: Array)
		equals: #( 'Today' 'This week' 'Monthly review' 'Late' 'Waiting for others' )
]

{ #category : 'tests - errors' }
NTItemViewSetTest >> testDuplicateNameSignals [

	self should: '{ "views" : [ { "name" : "A" }, { "name" : "A" } ] }' failWith: 'two views are named "A"'
]

{ #category : 'tests' }
NTItemViewSetTest >> testEmptySet [

	self assert: (NTItemViewSet fromText: (self text: '{ "views" : [ ] }')) views isEmpty.
	self assert: NTItemViewSet new text equals: (self text: '{
  "views" : [
  ]
}
')
]

{ #category : 'tests - errors' }
NTItemViewSetTest >> testInvalidJsonSignals [

	self should: '{ "views" : [ ' failWith: 'views.md is not valid JSON'
]

{ #category : 'tests - errors' }
NTItemViewSetTest >> testMissingViewsListSignals [

	self should: '{ "view" : [ ] }' failWith: 'views.md must have a "views" list'
]

{ #category : 'tests - errors' }
NTItemViewSetTest >> testNonBooleanSignals [

	self should: '{ "views" : [ { "name" : "A", "done" : "yes" } ] }' failWith: 'view "A": done must be true or false'
]

{ #category : 'tests' }
NTItemViewSetTest >> testReadDefaultsText [

	| set review |
	set := NTItemViewSet fromText: self defaultsText.
	self assert: set views size equals: 5.
	review := set viewNamed: 'Monthly review'.
	self assert: review period equals: 'month'.
	self assert: review includeNoDue.
	self assert: review groupBy equals: 'task'.
	self deny: review done.
	self assert: (set viewNamed: 'Waiting for others') has equals: #( 'waitingOthers' )
]

{ #category : 'tests' }
NTItemViewSetTest >> testRoundTrip [

	| text |
	text := NTItemViewSet defaults text.
	self assert: (NTItemViewSet fromText: text) text equals: text
]

{ #category : 'tests' }
NTItemViewSetTest >> testUnknownFieldsAreIgnored [

	| set |
	set := NTItemViewSet fromText: '{ "views" : [ { "name" : "Today", "period" : "today", "colour" : "red" } ] }'.
	self assert: (set viewNamed: 'Today') period equals: 'today'
]

{ #category : 'tests - errors' }
NTItemViewSetTest >> testUnknownGroupBySignals [

	self should: '{ "views" : [ { "name" : "A", "groupBy" : "tag" } ] }' failWith: 'view "A": unknown groupBy "tag"'
]

{ #category : 'tests - errors' }
NTItemViewSetTest >> testUnknownPeriodSignals [

	self should: '{ "views" : [ { "name" : "A", "period" : "tomorrow" } ] }' failWith: 'view "A": unknown period "tomorrow"'
]

{ #category : 'tests - errors' }
NTItemViewSetTest >> testUnknownSortBySignals [

	self should: '{ "views" : [ { "name" : "A", "sortBy" : "title" } ] }' failWith: 'view "A": unknown sortBy "title"'
]

{ #category : 'tests - errors' }
NTItemViewSetTest >> testViewWithoutNameSignals [

	self should: '{ "views" : [ { "period" : "today" } ] }' failWith: 'a view has no name'
]

{ #category : 'tests' }
NTItemViewSetTest >> testWriteAllFieldsInTableOrder [

	| set |
	set := NTItemViewSet new.
	set add: ((NTItemView named: 'Pharo "hot"')
			 sortBy: 'prio';
			 groupBy: 'section';
			 done: true;
			 has: #( 'prio(high)' );
			 includeNoDue: true;
			 period: 'next 3 days';
			 tags: #( 'work' 'urgent' );
			 sections: #( 'Pharo' );
			 yourself).
	self assert: set text equals: (self text: '{
  "views" : [
    { "name" : "Pharo \"hot\"", "sections" : [ "Pharo" ], "tags" : [ "work", "urgent" ], "period" : "next 3 days", "includeNoDue" : true, "has" : [ "prio(high)" ], "done" : true, "groupBy" : "section", "sortBy" : "prio" }
  ]
}
')
]

{ #category : 'tests' }
NTItemViewSetTest >> testWriteDefaults [

	self assert: NTItemViewSet defaults text equals: self defaultsText
]

{ #category : 'tests - errors' }
NTItemViewSetTest >> testWrongTypeSignals [

	self should: '{ "views" : [ { "name" : "A", "tags" : "work" } ] }' failWith: 'view "A": tags must be a list of strings'
]
