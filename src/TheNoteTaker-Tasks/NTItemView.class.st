"
I am a view: a named configuration that selects items across tasks, such as Today, This week or Monthly review. I have no query language, only a fixed set of fields.

## Responsibility:

- I know which tasks to look at (`sections`), which items to keep (`period`, `includeNoDue`, `tags`, `has`, `done`) and how to show them (`groupBy`, `sortBy`).
- I select the items of the open tasks of a repository on a given day, hiding items whose `@start` is later.
- I group and sort the selected items.

## Collaborators: 

- `NTTaskRepository`: where the tasks come from.
- `NTViewEntry`: an item I select, with its task.
- `NTItemViewSet`: holds me and saves me in `views.md`.

## Public API and Key Messages

- `NTItemView named: 'This week'` then `period: 'week'`, `sections:`, `tags:`, `has:`, `includeNoDue:`, `done:`, `groupBy:`, `sortBy:`
- `entriesIn: aRepository on: aDate` answers the sorted entries.
- `groupsIn: aRepository on: aDate` answers group name -> entries (one group named nil without `groupBy`).
- `NTItemView isValidPeriod: 'next 3 days'`

```
(NTItemView named: 'Monthly review')
	period: 'month';
	includeNoDue: true;
	groupBy: 'task';
	entriesIn: aRepository on: Date today
```

See `NTItemView class >> #exampleMonthlyReview`.

## Internal Representation

- `period`: nil (no date condition), 'today', 'week' (Monday to Sunday), 'month', 'next N days' or 'overdue'. The date of an item is its `@due`, or its `@start` when it has no `@due`; overdue only looks at `@due`.
- `sections`, `tags`, `has`: Arrays of Strings; `has` entries are key names (`waitingOthers`) or key(value) (`prio(high)`).
- `includeNoDue`, `done`: Booleans.
- `groupBy`: nil, 'task', 'section' or 'waitingOthers'; `sortBy`: nil (file order), 'due', 'prio' or 'created'.
"
Class {
	#name : 'NTItemView',
	#superclass : 'Object',
	#instVars : [
		'name',
		'period',
		'includeNoDue',
		'sections',
		'tags',
		'has',
		'done',
		'groupBy',
		'sortBy'
	],
	#category : 'TheNoteTaker-Tasks-Views',
	#package : 'TheNoteTaker-Tasks',
	#tag : 'Views'
}

{ #category : 'examples' }
NTItemView class >> exampleMonthlyReview [
	"The items due this month, and those with no date, grouped by task."

	<sampleInstance>
	^ (self named: 'Monthly review')
		  period: 'month';
		  includeNoDue: true;
		  groupBy: 'task';
		  yourself
]

{ #category : 'accessing' }
NTItemView class >> fixedPeriods [
	"The periods other than 'next N days'."

	^ #( 'today' 'week' 'month' 'overdue' )
]

{ #category : 'accessing' }
NTItemView class >> groupings [

	^ #( 'task' 'section' 'waitingOthers' )
]

{ #category : 'testing' }
NTItemView class >> isValidPeriod: aStringOrNil [
	"Answer whether aStringOrNil is a period I understand: nil (no period), one of the fixed periods, or 'next N days' with N > 0."

	aStringOrNil ifNil: [ ^ true ].
	^ (self fixedPeriods includes: aStringOrNil) or: [ aStringOrNil matchesRegex: 'next [1-9][0-9]* days' ]
]

{ #category : 'instance creation' }
NTItemView class >> named: aString [

	^ self new
		  name: aString;
		  yourself
]

{ #category : 'accessing' }
NTItemView class >> sortings [

	^ #( 'due' 'prio' 'created' )
]

{ #category : 'copying' }
NTItemView >> copyFieldsFrom: aView [
	"Take all the fields of aView, its name included, keeping my identity (and my place in my view set)."

	name := aView name.
	sections := aView sections.
	tags := aView tags.
	period := aView period.
	includeNoDue := aView includeNoDue.
	has := aView has.
	done := aView done.
	groupBy := aView groupBy.
	sortBy := aView sortBy
]

{ #category : 'accessing' }
NTItemView >> done [

	^ done
]

{ #category : 'accessing' }
NTItemView >> done: aBoolean [

	done := aBoolean
]

{ #category : 'selecting' }
NTItemView >> entriesIn: aRepository on: aDate [
	"Answer the entries of the items I select among the open tasks of aRepository on aDate, sorted."

	^ self sort: ((aRepository openTasks select: [ :task | self includesTask: task ])
			   flatCollect: [ :task |
				   task items select: [ :item | self includesItem: item on: aDate ] thenCollect: [ :item | NTViewEntry item: item task: task ] ]
			   as: OrderedCollection)
]

{ #category : 'accessing' }
NTItemView >> groupBy [

	^ groupBy
]

{ #category : 'accessing' }
NTItemView >> groupBy: aStringOrNil [

	groupBy := aStringOrNil
]

{ #category : 'sorting and grouping' }
NTItemView >> groupNameOf: anEntry [

	groupBy = 'task' ifTrue: [ ^ anEntry task title ].
	groupBy = 'section' ifTrue: [ ^ anEntry task sectionName ].
	groupBy = 'waitingOthers' ifTrue: [ ^ self waitingGroupNameOf: anEntry item ].
	^ nil
]

{ #category : 'selecting' }
NTItemView >> groupsIn: aRepository on: aDate [
	"Answer an OrderedDictionary group name -> entries, groups in the order they first appear. Without groupBy, all entries are in one group named nil."

	^ (self entriesIn: aRepository on: aDate) groupedBy: [ :each | self groupNameOf: each ]
]

{ #category : 'accessing' }
NTItemView >> has [

	^ has
]

{ #category : 'accessing' }
NTItemView >> has: aCollection [

	has := aCollection asArray
]

{ #category : 'accessing' }
NTItemView >> includeNoDue [

	^ includeNoDue
]

{ #category : 'accessing' }
NTItemView >> includeNoDue: aBoolean [

	includeNoDue := aBoolean
]

{ #category : 'selecting' }
NTItemView >> includesItem: anItem on: aDate [

	(done or: [ anItem isDone not ]) ifFalse: [ ^ false ].
	(anItem isVisibleOn: aDate) ifFalse: [ ^ false ].
	(tags allSatisfy: [ :each | anItem hasTag: each ]) ifFalse: [ ^ false ].
	(has allSatisfy: [ :each | self item: anItem has: each ]) ifFalse: [ ^ false ].
	^ self isInPeriod: anItem on: aDate
]

{ #category : 'selecting' }
NTItemView >> includesTask: aTask [

	^ sections isNil or: [ sections includes: aTask sectionName ]
]

{ #category : 'initialization' }
NTItemView >> initialize [

	super initialize.
	includeNoDue := false.
	done := false.
	tags := #(  ).
	has := #(  )
]

{ #category : 'periods' }
NTItemView >> isInPeriod: anItem on: aDate [
	"The date of an item is its @due, or its @start when it has no @due. Overdue only looks at @due."

	| date |
	period ifNil: [ ^ true ].
	period = 'overdue' ifTrue: [ ^ (anItem isLateOn: aDate) or: [ includeNoDue and: [ anItem due isNil ] ] ].
	date := anItem due ifNil: [ anItem start ].
	date ifNil: [ ^ includeNoDue ].
	^ date between: (self periodStartOn: aDate) and: (self periodEndOn: aDate)
]

{ #category : 'selecting' }
NTItemView >> item: anItem has: aString [
	"aString is a key name, such as 'waitingOthers', or a key with its value, such as 'prio(high)'."

	| open |
	open := aString indexOf: $(.
	open = 0 ifTrue: [ ^ anItem hasKey: aString ].
	^ (anItem keyAt: (aString first: open - 1)) = (aString copyFrom: open + 1 to: aString size - 1)
]

{ #category : 'accessing' }
NTItemView >> name [

	^ name
]

{ #category : 'accessing' }
NTItemView >> name: aString [

	name := aString
]

{ #category : 'periods' }
NTItemView >> nextDaysCount [
	"Answer N of 'next N days'."

	^ (period substrings: ' ') second asNumber
]

{ #category : 'accessing' }
NTItemView >> period [

	^ period
]

{ #category : 'accessing' }
NTItemView >> period: aStringOrNil [

	period := aStringOrNil
]

{ #category : 'periods' }
NTItemView >> periodEndOn: aDate [

	period = 'week' ifTrue: [ ^ (self periodStartOn: aDate) addDays: 6 ].
	period = 'month' ifTrue: [ ^ Date year: aDate year month: aDate monthIndex day: aDate daysInMonth ].
	(period beginsWith: 'next ') ifTrue: [ ^ aDate addDays: self nextDaysCount - 1 ].
	^ aDate
]

{ #category : 'periods' }
NTItemView >> periodStartOn: aDate [
	"A week starts on Monday."

	period = 'week' ifTrue: [ ^ aDate addDays: (aDate dayOfWeek + 5 \\ 7) negated ].
	period = 'month' ifTrue: [ ^ Date year: aDate year month: aDate monthIndex day: 1 ].
	^ aDate
]

{ #category : 'printing' }
NTItemView >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: name asString;
		nextPut: $)
]

{ #category : 'accessing' }
NTItemView >> sections [
	"Answer the section names to look at, or nil for all sections."

	^ sections
]

{ #category : 'accessing' }
NTItemView >> sections: aCollectionOrNil [
	"An empty collection means all sections, as nil."

	sections := (aCollectionOrNil isNil or: [ aCollectionOrNil isEmpty ])
		            ifTrue: [ nil ]
		            ifFalse: [ aCollectionOrNil asArray ]
]

{ #category : 'sorting and grouping' }
NTItemView >> sort: entries [
	"Sort on sortBy, items without a value last; equal items keep their order."

	| keyBlock |
	sortBy ifNil: [ ^ entries ].
	keyBlock := self sortKeyBlock.
	^ entries sorted: [ :a :b |
			  | x y |
			  x := keyBlock value: a item.
			  y := keyBlock value: b item.
			  y isNil or: [ x isNotNil and: [ x <= y ] ] ]
]

{ #category : 'accessing' }
NTItemView >> sortBy [

	^ sortBy
]

{ #category : 'accessing' }
NTItemView >> sortBy: aStringOrNil [

	sortBy := aStringOrNil
]

{ #category : 'sorting and grouping' }
NTItemView >> sortKeyBlock [

	sortBy = 'due' ifTrue: [ ^ [ :item | item due ] ].
	sortBy = 'created' ifTrue: [ ^ [ :item | item createdDate ] ].
	^ [ :item | #( 'high' nil 'low' ) indexOf: item prio ]
]

{ #category : 'accessing' }
NTItemView >> tags [

	^ tags
]

{ #category : 'accessing' }
NTItemView >> tags: aCollection [

	tags := aCollection asArray
]

{ #category : 'sorting and grouping' }
NTItemView >> waitingGroupNameOf: anItem [

	anItem isWaitingOthers ifFalse: [ ^ 'Not waiting' ].
	^ anItem waitingOthers ifNil: [ 'Someone' ] ifNotNil: [ :someone | someone ifEmpty: [ 'Someone' ] ]
]
