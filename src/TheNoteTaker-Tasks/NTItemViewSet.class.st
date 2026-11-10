"
I hold the views of a tasks folder and convert them from and to the text of `views.md`, one view per line.

```
{
  ""views"" : [
    { ""name"" : ""Today"", ""period"" : ""today"" },
    { ""name"" : ""Waiting for others"", ""has"" : [ ""waitingOthers"" ], ""groupBy"" : ""waitingOthers"" }
  ]
}
```

## Responsibility:

- I keep the views in order and add, remove and find them by name.
- I answer the default views (Today, This week, Monthly review, Late, Waiting for others) used when there is no `views.md`.
- I read and write `views.md`, signalling `NTViewsFormatError` when its text cannot be read.

## Collaborators: 

- `NTItemView`: the views I hold.
- `NTTaskRepository`: loads and saves me in its folder.
- `STONJSON` / `STONReader`: read and escape JSON.

## Public API and Key Messages

- `NTItemViewSet defaults`, `NTItemViewSet fromText: aString`, `text`
- `views`, `add:`, `remove:`, `viewNamed:`

See `NTItemViewSet class >> #exampleDefaults`.

## Internal Representation

- `views`: an OrderedCollection of `NTItemView`.

### Implementation Points

- Fields with their default value are not written, and unknown fields of a view are not kept.
"
Class {
	#name : 'NTItemViewSet',
	#superclass : 'Object',
	#instVars : [
		'views'
	],
	#category : 'TheNoteTaker-Tasks-Views',
	#package : 'TheNoteTaker-Tasks',
	#tag : 'Views'
}

{ #category : 'instance creation' }
NTItemViewSet class >> defaults [
	"The views of a folder without views.md."

	^ self new
		  add: ((NTItemView named: 'Today')
				   period: 'today';
				   yourself);
		  add: ((NTItemView named: 'This week')
				   period: 'week';
				   yourself);
		  add: NTItemView exampleMonthlyReview;
		  add: ((NTItemView named: 'Late')
				   period: 'overdue';
				   yourself);
		  add: ((NTItemView named: 'Waiting for others')
				   has: #( 'waitingOthers' );
				   groupBy: 'waitingOthers';
				   yourself);
		  yourself
]

{ #category : 'examples' }
NTItemViewSet class >> exampleDefaults [

	<sampleInstance>
	^ self defaults
]

{ #category : 'instance creation' }
NTItemViewSet class >> fromText: aString [
	"Answer the views written in aString, the text of views.md. Signal NTViewsFormatError when it cannot be read."

	^ self new
		  readText: aString;
		  yourself
]

{ #category : 'accessing' }
NTItemViewSet >> add: aView [

	views add: aView.
	^ aView
]

{ #category : 'reading' }
NTItemViewSet >> booleanAt: aKey in: aDictionary [

	| value |
	value := aDictionary at: aKey ifAbsent: [ ^ false ].
	({ true. false } includes: value) ifFalse: [ ^ self fail: aKey , ' must be true or false' in: aDictionary ].
	^ value
]

{ #category : 'reading' }
NTItemViewSet >> checkUniqueNames [

	views
		detect: [ :view | (views count: [ :each | each name = view name ]) > 1 ]
		ifFound: [ :view | self fail: ('two views are named "{1}"' format: { view name }) ]
]

{ #category : 'reading' }
NTItemViewSet >> choiceAt: aKey in: aDictionary valid: aBlock [
	"Answer the value of aKey, nil when absent, signalling an error when aBlock rejects it."

	| value |
	value := aDictionary at: aKey ifAbsent: [ ^ nil ].
	(value isString and: [ aBlock value: value ]) ifFalse: [
			^ self
				  fail: ('unknown {1} "{2}"' format: {
							   aKey.
							   value })
				  in: aDictionary ].
	^ value
]

{ #category : 'reading' }
NTItemViewSet >> fail: aString [

	^ NTViewsFormatError signal: aString
]

{ #category : 'reading' }
NTItemViewSet >> fail: aString in: aViewDictionary [

	^ self fail: ('view "{1}": {2}' format: {
				   (aViewDictionary at: 'name').
				   aString })
]

{ #category : 'writing' }
NTItemViewSet >> fieldsOf: aView [
	"Answer the fields of aView that do not have their default value, as name -> value."

	| fields |
	fields := OrderedCollection with: 'name' -> aView name.
	aView sections ifNotNil: [ :value | fields add: 'sections' -> value ].
	aView tags ifNotEmpty: [ :value | fields add: 'tags' -> value ].
	aView period ifNotNil: [ :value | fields add: 'period' -> value ].
	aView includeNoDue ifTrue: [ fields add: 'includeNoDue' -> true ].
	aView has ifNotEmpty: [ :value | fields add: 'has' -> value ].
	aView done ifTrue: [ fields add: 'done' -> true ].
	aView groupBy ifNotNil: [ :value | fields add: 'groupBy' -> value ].
	aView sortBy ifNotNil: [ :value | fields add: 'sortBy' -> value ].
	^ fields
]

{ #category : 'initialization' }
NTItemViewSet >> initialize [

	super initialize.
	views := OrderedCollection new
]

{ #category : 'writing' }
NTItemViewSet >> jsonOf: aValue [
	"A string, a boolean, or an Array of strings written on one line, with spaces inside the brackets."

	aValue isArray ifFalse: [ ^ STONJSON toString: aValue ].
	^ '[ {1} ]' format: { (', ' join: (aValue collect: [ :each | STONJSON toString: each ])) }
]

{ #category : 'writing' }
NTItemViewSet >> lineOf: aView [

	^ String streamContents: [ :stream |
			  stream nextPutAll: '{ '.
			  (self fieldsOf: aView)
				  do: [ :each |
						  stream
							  nextPutAll: (STONJSON toString: each key);
							  nextPutAll: ' : ';
							  nextPutAll: (self jsonOf: each value) ]
				  separatedBy: [ stream nextPutAll: ', ' ].
			  stream nextPutAll: ' }' ]
]

{ #category : 'reading' }
NTItemViewSet >> readText: aString [

	| json |
	json := [ STONJSON fromString: aString ]
		        on: STONReaderError
		        do: [ ^ self fail: 'views.md is not valid JSON' ].
	(json isDictionary and: [ (json at: 'views' ifAbsent: [ nil ]) isArray ]) ifFalse: [
		^ self fail: 'views.md must have a "views" list' ].
	views := (json at: 'views') collect: [ :each | self readView: each ] as: OrderedCollection.
	self checkUniqueNames
]

{ #category : 'reading' }
NTItemViewSet >> readView: aDictionary [

	| name |
	name := aDictionary isDictionary ifTrue: [ aDictionary at: 'name' ifAbsent: [ nil ] ].
	(name isString and: [ name isNotEmpty ]) ifFalse: [ ^ self fail: 'a view has no name' ].
	^ (NTItemView named: name)
		  sections: (self stringsAt: 'sections' in: aDictionary);
		  tags: (self stringsAt: 'tags' in: aDictionary);
		  has: (self stringsAt: 'has' in: aDictionary);
		  period: (self choiceAt: 'period' in: aDictionary valid: [ :each | NTItemView isValidPeriod: each ]);
		  groupBy: (self choiceAt: 'groupBy' in: aDictionary valid: [ :each | NTItemView groupings includes: each ]);
		  sortBy: (self choiceAt: 'sortBy' in: aDictionary valid: [ :each | NTItemView sortings includes: each ]);
		  includeNoDue: (self booleanAt: 'includeNoDue' in: aDictionary);
		  done: (self booleanAt: 'done' in: aDictionary);
		  yourself
]

{ #category : 'accessing' }
NTItemViewSet >> remove: aView [

	^ views remove: aView
]

{ #category : 'reading' }
NTItemViewSet >> stringsAt: aKey in: aDictionary [

	| value |
	value := aDictionary at: aKey ifAbsent: [ ^ #(  ) ].
	(value isArray and: [ value allSatisfy: [ :each | each isString ] ]) ifFalse: [
		^ self fail: aKey , ' must be a list of strings' in: aDictionary ].
	^ value
]

{ #category : 'writing' }
NTItemViewSet >> text [
	"Answer the text of views.md: one view per line, LF line endings."

	^ String streamContents: [ :stream |
			  stream
				  nextPut: ${;
				  nextPut: Character lf;
				  nextPutAll: '  "views" : [';
				  nextPut: Character lf.
			  views
				  do: [ :each |
						  stream
							  nextPutAll: '    ';
							  nextPutAll: (self lineOf: each) ]
				  separatedBy: [
						  stream
							  nextPut: $,;
							  nextPut: Character lf ].
			  views ifNotEmpty: [ stream nextPut: Character lf ].
			  stream
				  nextPutAll: '  ]';
				  nextPut: Character lf;
				  nextPut: $};
				  nextPut: Character lf ]
]

{ #category : 'accessing' }
NTItemViewSet >> viewNamed: aString [

	^ views detect: [ :each | each name = aString ] ifNone: [ nil ]
]

{ #category : 'accessing' }
NTItemViewSet >> views [

	^ views
]
