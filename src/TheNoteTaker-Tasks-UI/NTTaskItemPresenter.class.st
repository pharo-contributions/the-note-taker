"
I edit the details of one task item: its description and the keys the app understands, and I show its other keys.

## Responsibility:

- I edit the description, `@due` and `@start` (dates, empty means no key), `@prio` (normal, high, low), `@waitingOthers` (on or off, with an optional name), `@note`, `@url` and `@every`.
- I list the keys the app does not understand, as key = value rows whose value can be edited.
- I tell my owner after every change, so the task is saved.

## Collaborators: 

- `NTTaskItem`: my model.
- `NTTaskItemsPresenter`: my owner.

## Public API and Key Messages

- `whenItemChangedDo: aBlock`
- the sub-presenters (`dueDate`, `prioList`, `waitingCheckBox`, …) are reachable for tests.

See `NTTaskItemPresenter class >> #exampleOnItem`.

## Internal Representation

- `dueDate`, `startDate`: `SpDatePresenter`s; `prioList`: an `SpDropListPresenter` on `#(nil 'high' 'low')`.
- `otherKeysTable`: an `SpTablePresenter` of `NTItemKey`s.
- `changedBlock`: evaluated after each change; `isUpdating` is true while the fields are filled from the item, so that is not a change.
"
Class {
	#name : 'NTTaskItemPresenter',
	#superclass : 'SpPresenterWithModel',
	#instVars : [
		'descriptionText',
		'dueDate',
		'startDate',
		'prioList',
		'waitingCheckBox',
		'waitingInput',
		'noteInput',
		'urlInput',
		'everyInput',
		'otherKeysTable',
		'changedBlock',
		'isUpdating'
	],
	#category : 'TheNoteTaker-Tasks-UI',
	#package : 'TheNoteTaker-Tasks-UI'
}

{ #category : 'examples' }
NTTaskItemPresenter class >> exampleOnItem [

	<sampleInstance>
	^ self newApplication: NTTasksApplication new model: NTTaskItem exampleReleaseNotes
]

{ #category : 'accessing' }
NTTaskItemPresenter class >> knownKeyNames [
	"The keys edited by a field of their own; @done and @created are set by the app."

	^ #( 'due' 'start' 'prio' 'waitingOthers' 'note' 'url' 'every' 'done' 'created' )
]

{ #category : 'private' }
NTTaskItemPresenter >> change: aBlock [
	"Apply aBlock to the item and tell the owner, unless the fields are being filled from the item."

	(isUpdating or: [ self model isNil ]) ifTrue: [ ^ self ].
	aBlock value: self model.
	changedBlock value
]

{ #category : 'initialization' }
NTTaskItemPresenter >> connectDescriptionAndDates [

	descriptionText whenTextChangedDo: [ :text | self change: [ :item | item description: text asString ] ].
	dueDate whenDateChanged: [ :date | self change: [ :item | item due: date ] ].
	startDate whenDateChanged: [ :date | self change: [ :item | item start: date ] ]
]

{ #category : 'initialization' }
NTTaskItemPresenter >> connectKeyInputs [
	"Each of these inputs edits one key; an empty input removes the key."

	{
		(noteInput -> 'note').
		(urlInput -> 'url').
		(everyInput -> 'every') } do: [ :each |
		each key whenTextChangedDo: [ :text | self change: [ :item | self key: each value of: item text: text ] ] ]
]

{ #category : 'initialization' }
NTTaskItemPresenter >> connectPresenters [

	self connectDescriptionAndDates.
	self connectPriorityAndWaiting.
	self connectKeyInputs
]

{ #category : 'initialization' }
NTTaskItemPresenter >> connectPriorityAndWaiting [

	prioList whenSelectedItemChangedDo: [ :prio | self change: [ :item | item prio: prio ] ].
	waitingCheckBox whenChangedDo: [ self change: [ :item | self updateWaitingOf: item ] ].
	waitingInput whenTextChangedDo: [ self change: [ :item | self updateWaitingOf: item ] ]
]

{ #category : 'layout' }
NTTaskItemPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: 'Description' expand: false;
		  add: descriptionText height: 80;
		  add: (self row: 'Due' with: dueDate) expand: false;
		  add: (self row: 'Start' with: startDate) expand: false;
		  add: (self row: 'Priority' with: prioList) expand: false;
		  add: (SpBoxLayout newLeftToRight
				   add: waitingCheckBox;
				   add: waitingInput;
				   yourself)
		  expand: false;
		  add: (self row: 'Note' with: noteInput) expand: false;
		  add: (self row: 'Url' with: urlInput) expand: false;
		  add: (self row: 'Every' with: everyInput) expand: false;
		  add: 'Other keys' expand: false;
		  add: otherKeysTable;
		  yourself
]

{ #category : 'accessing' }
NTTaskItemPresenter >> descriptionText [

	^ descriptionText
]

{ #category : 'accessing' }
NTTaskItemPresenter >> dueDate [

	^ dueDate
]

{ #category : 'accessing' }
NTTaskItemPresenter >> everyInput [

	^ everyInput
]

{ #category : 'initialization' }
NTTaskItemPresenter >> initializePresenters [

	isUpdating := false.
	changedBlock := [ ].
	descriptionText := self newText.
	dueDate := self instantiate: SpDatePresenter.
	startDate := self instantiate: SpDatePresenter.
	prioList := self newPriorityList.
	waitingCheckBox := self newCheckBox
		                   label: 'Waiting for others';
		                   yourself.
	waitingInput := self newInputWithPlaceholder: 'who (optional)'.
	noteInput := self newInputWithPlaceholder: 'note file name'.
	urlInput := self newInputWithPlaceholder: 'https://...'.
	everyInput := self newInputWithPlaceholder: 'week, month, 2d...'.
	otherKeysTable := self newOtherKeysTable
]

{ #category : 'private' }
NTTaskItemPresenter >> key: aName of: anItem text: aText [

	| value |
	value := aText asString trimBoth.
	value ifEmpty: [ anItem removeKey: aName ] ifNotEmpty: [ anItem keyAt: aName put: value ]
]

{ #category : 'initialization' }
NTTaskItemPresenter >> modelChanged [

	self updatePresenter
]

{ #category : 'initialization' }
NTTaskItemPresenter >> newInputWithPlaceholder: aString [

	^ self newTextInput
		  placeholder: aString;
		  yourself
]

{ #category : 'initialization' }
NTTaskItemPresenter >> newOtherKeysTable [
	"A table of the keys without a field of their own; their value can be edited."

	| valueColumn |
	valueColumn := (SpStringTableColumn title: 'Value' evaluated: [ :key | key value ifNil: [ '' ] ])
		               beEditable;
		               onAcceptEdition: [ :key :text | self otherKey: key value: text ];
		               yourself.
	^ self newTable
		  addColumn: (SpStringTableColumn title: 'Key' evaluated: [ :key | key name ]);
		  addColumn: valueColumn;
		  yourself
]

{ #category : 'initialization' }
NTTaskItemPresenter >> newPriorityList [

	^ self newDropList
		  items: #( nil 'high' 'low' );
		  display: [ :each | each ifNil: [ 'normal' ] ];
		  yourself
]

{ #category : 'accessing' }
NTTaskItemPresenter >> noteInput [

	^ noteInput
]

{ #category : 'actions' }
NTTaskItemPresenter >> otherKey: aKey value: aString [
	"Set the value of a key that has no field of its own; an empty value makes a key without value."

	self change: [ :item | item keyAt: aKey name put: (aString asString trimBoth ifEmpty: [ nil ]) ]
]

{ #category : 'private' }
NTTaskItemPresenter >> otherKeysOf: anItem [
	"Answer the keys of anItem that have no field of their own."

	^ anItem keys reject: [ :each | self class knownKeyNames includes: each name ]
]

{ #category : 'accessing' }
NTTaskItemPresenter >> otherKeysTable [

	^ otherKeysTable
]

{ #category : 'accessing' }
NTTaskItemPresenter >> prioList [

	^ prioList
]

{ #category : 'initialization' }
NTTaskItemPresenter >> row: aLabel with: aPresenter [

	^ SpBoxLayout newLeftToRight
		  add: aLabel width: 70;
		  add: aPresenter;
		  yourself
]

{ #category : 'updating' }
NTTaskItemPresenter >> showItem: anItem [

	descriptionText text: anItem description.
	dueDate date: anItem due.
	startDate date: anItem start.
	prioList selectItem: anItem prio.
	waitingCheckBox state: anItem isWaitingOthers.
	waitingInput text: (anItem waitingOthers ifNil: [ '' ]).
	noteInput text: (anItem note ifNil: [ '' ]).
	urlInput text: (anItem url ifNil: [ '' ]).
	everyInput text: (anItem every ifNil: [ '' ]).
	otherKeysTable items: (self otherKeysOf: anItem)
]

{ #category : 'updating' }
NTTaskItemPresenter >> showNoItem [

	descriptionText text: ''.
	dueDate date: nil.
	startDate date: nil.
	prioList selectItem: nil.
	waitingCheckBox state: false.
	{
		waitingInput.
		noteInput.
		urlInput.
		everyInput } do: [ :each | each text: '' ].
	otherKeysTable items: #(  )
]

{ #category : 'accessing' }
NTTaskItemPresenter >> startDate [

	^ startDate
]

{ #category : 'updating' }
NTTaskItemPresenter >> updatePresenter [
	"Show the model in the fields. Setting the fields here is not a change of the item."

	isUpdating := true.
	[ self model ifNil: [ self showNoItem ] ifNotNil: [ :item | self showItem: item ] ] ensure: [ isUpdating := false ]
]

{ #category : 'private' }
NTTaskItemPresenter >> updateWaitingOf: anItem [
	"Typing a name implies waiting; an empty name with the box ticked is @waitingOthers without value."

	| name |
	name := waitingInput text asString trimBoth.
	name ifNotEmpty: [
			isUpdating := true.
			[ waitingCheckBox state: true ] ensure: [ isUpdating := false ] ].
	waitingCheckBox state
		ifTrue: [ anItem waitingOthers: (name ifEmpty: [ nil ]) ]
		ifFalse: [ anItem removeKey: 'waitingOthers' ]
]

{ #category : 'accessing' }
NTTaskItemPresenter >> urlInput [

	^ urlInput
]

{ #category : 'accessing' }
NTTaskItemPresenter >> waitingCheckBox [

	^ waitingCheckBox
]

{ #category : 'accessing' }
NTTaskItemPresenter >> waitingInput [

	^ waitingInput
]

{ #category : 'announcing' }
NTTaskItemPresenter >> whenItemChangedDo: aBlock [

	changedBlock := aBlock
]
