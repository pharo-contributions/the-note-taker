"
I show the items a view (`NTItemView`) selects, grouped as the view says, with a filter field. My model is the view.

## Responsibility:

- I list the selected items with their task, due date and annotations, under their group when the view groups them.
- I narrow the list with the text of the filter field (a word or a #tag), which is never saved.
- I tick and untick items; the task is saved at once.
- I ask my owner to open the task of an item when it is double-clicked.

## Collaborators: 

- `NTItemView`: selects, groups and sorts the entries.
- `NTViewEntry`: an item with its task; `matchesFilter:` implements the filter.
- `NTTaskRepository`: where tasks are read and saved.
- `NTTasksApplication>>#today`: the day the view is computed for.

## Public API and Key Messages

- `NTItemViewPresenter newApplication: anApplication model: aView`, then `repository: aRepository`
- `refresh`, `filter: aString`, `entries`, `roots`, `toggle: anEntry`, `requestTaskOf: anEntry`
- `whenTaskRequestedDo: aBlock` (with the task), `whenItemsChangedDo: aBlock`

See `NTItemViewPresenter class >> #exampleThisWeek`.

## Internal Representation

- `repository`: the `NTTaskRepository`.
- `titleLabel`, `filterInput`: the header.
- `entriesTree`: an `SpTreeTablePresenter`; its roots are entries, or group names when the view groups items.
- `groups`: the last computed groups, group name -> entries, before filtering.
- `taskRequestedBlock`, `changedBlock`: the owner's callbacks.
"
Class {
	#name : 'NTItemViewPresenter',
	#superclass : 'SpPresenterWithModel',
	#instVars : [
		'repository',
		'titleLabel',
		'filterInput',
		'entriesTree',
		'groups',
		'taskRequestedBlock',
		'changedBlock'
	],
	#category : 'TheNoteTaker-Tasks-UI',
	#package : 'TheNoteTaker-Tasks-UI'
}

{ #category : 'examples' }
NTItemViewPresenter class >> exampleThisWeek [

	<sampleInstance>
	| application |
	application := NTTasksApplication new.
	^ (self newApplication: application model: ((NTItemView named: 'This week')
				    period: 'week';
				    includeNoDue: true;
				    groupBy: 'task';
				    yourself))
		  repository: NTTasksApplication demoRepository;
		  yourself
]

{ #category : 'private' }
NTItemViewPresenter >> annotationsOf: aNode [

	^ aNode isString
		  ifTrue: [ '' ]
		  ifFalse: [ aNode item displayAnnotations ]
]

{ #category : 'accessing' }
NTItemViewPresenter >> childrenOf: aNode [
	"Only group names, which are strings, have children."

	aNode isString ifFalse: [ ^ #(  ) ].
	^ self matchingIn: (groups at: aNode ifAbsent: [ #(  ) ])
]

{ #category : 'initialization' }
NTItemViewPresenter >> connectPresenters [

	filterInput whenTextChangedDo: [ self refreshTree ].
	entriesTree whenActivatedDo: [ :selection | self requestTaskOf: selection selectedItem ]
]

{ #category : 'layout' }
NTItemViewPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 8;
				   add: titleLabel;
				   add: filterInput width: 250;
				   yourself)
		  expand: false;
		  add: entriesTree;
		  yourself
]

{ #category : 'private' }
NTItemViewPresenter >> dueOf: aNode [

	aNode isString ifTrue: [ ^ '' ].
	^ aNode item due ifNil: [ '' ] ifNotNil: [ :date | date yyyymmdd ]
]

{ #category : 'accessing' }
NTItemViewPresenter >> entries [
	"Answer the entries shown, in group order, after filtering."

	^ groups values flatCollect: [ :each | self matchingIn: each ]
]

{ #category : 'accessing' }
NTItemViewPresenter >> entriesTree [

	^ entriesTree
]

{ #category : 'accessing' }
NTItemViewPresenter >> filter: aString [
	"Narrow the list as if aString was typed in the filter field."

	filterInput text: aString
]

{ #category : 'accessing' }
NTItemViewPresenter >> filterInput [

	^ filterInput
]

{ #category : 'private' }
NTItemViewPresenter >> headerTitle [

	| total shown |
	self model ifNil: [ ^ '' ].
	total := groups values inject: 0 into: [ :sum :each | sum + each size ].
	shown := self entries size.
	shown = total ifTrue: [
			^ '{1}  ({2})' format: {
					  self model name.
					  total } ].
	^ '{1}  ({2} of {3})' format: {
			  self model name.
			  shown.
			  total }
]

{ #category : 'initialization' }
NTItemViewPresenter >> initializePresenters [

	taskRequestedBlock := [ :task |  ].
	changedBlock := [ ].
	groups := OrderedDictionary new.
	titleLabel := self newLabel.
	filterInput := self newTextInput
		               placeholder: 'Filter: a word or #tag';
		               yourself.
	entriesTree := self newEntriesTree
]

{ #category : 'private' }
NTItemViewPresenter >> matchingIn: entries [

	^ entries select: [ :each | each matchesFilter: filterInput text ]
]

{ #category : 'initialization' }
NTItemViewPresenter >> modelChanged [

	self updatePresenter
]

{ #category : 'initialization' }
NTItemViewPresenter >> newDoneColumn [
	"Group rows are strings: Spec shows them an unticked box, which does nothing."

	^ (SpCheckBoxTableColumn evaluated: [ :node | node isString not and: [ node item isDone ] ])
		  onActivation: [ :node | self toggle: node ];
		  onDeactivation: [ :node | self toggle: node ];
		  width: 20;
		  yourself
]

{ #category : 'initialization' }
NTItemViewPresenter >> newEntriesTree [

	^ self newTreeTable
		  addColumn: self newItemColumn;
		  addColumn: (SpStringTableColumn title: 'Task' evaluated: [ :node | self taskTitleOf: node ]);
		  addColumn: (SpStringTableColumn title: 'Due' evaluated: [ :node | self dueOf: node ]);
		  addColumn: (SpStringTableColumn title: 'Keys and tags' evaluated: [ :node | self annotationsOf: node ]);
		  children: [ :node | self childrenOf: node ];
		  yourself
]

{ #category : 'initialization' }
NTItemViewPresenter >> newItemColumn [
	"The checkbox and the title in one column, so the tree indentation does not squeeze the checkbox."

	^ (SpCompositeTableColumn title: 'Item')
		  addColumn: self newDoneColumn;
		  addColumn: (SpStringTableColumn evaluated: [ :node | self titleOf: node ]);
		  width: 280;
		  yourself
]

{ #category : 'updating' }
NTItemViewPresenter >> refresh [
	"Select the items again, for instance after a task changed."

	groups := (self model isNil or: [ repository isNil ])
		          ifTrue: [ OrderedDictionary new ]
		          ifFalse: [ self model groupsIn: repository on: self application today ].
	self refreshTree
]

{ #category : 'updating' }
NTItemViewPresenter >> refreshTree [

	entriesTree roots: self roots.
	entriesTree expandAll.
	titleLabel label: self headerTitle
]

{ #category : 'accessing' }
NTItemViewPresenter >> repository [

	^ repository
]

{ #category : 'accessing' }
NTItemViewPresenter >> repository: aRepository [

	repository := aRepository.
	self refresh
]

{ #category : 'actions' }
NTItemViewPresenter >> requestTaskOf: aNode [
	"Ask the owner to show the task of an entry. Group rows have no task."

	(aNode isNil or: [ aNode isString ]) ifTrue: [ ^ self ].
	taskRequestedBlock value: aNode task
]

{ #category : 'accessing' }
NTItemViewPresenter >> roots [

	self model ifNil: [ ^ #(  ) ].
	self model groupBy ifNil: [ ^ self entries ].
	^ groups keys select: [ :each | (self childrenOf: each) isNotEmpty ]
]

{ #category : 'private' }
NTItemViewPresenter >> taskTitleOf: aNode [

	^ aNode isString
		  ifTrue: [ '' ]
		  ifFalse: [ aNode task title ]
]

{ #category : 'accessing' }
NTItemViewPresenter >> titleLabel [

	^ titleLabel
]

{ #category : 'private' }
NTItemViewPresenter >> titleOf: aNode [

	^ aNode isString
		  ifTrue: [ aNode ]
		  ifFalse: [ aNode item title ]
]

{ #category : 'actions' }
NTItemViewPresenter >> toggle: aNode [
	"Tick or untick the item of an entry and save its task. A group row stays unticked."

	aNode isString ifTrue: [ ^ self refreshTree ].
	aNode item isDone
		ifTrue: [ aNode item markUndone ]
		ifFalse: [ aNode item markDoneOn: self application today ].
	repository save: aNode task.
	self refresh.
	changedBlock value
]

{ #category : 'updating' }
NTItemViewPresenter >> updatePresenter [

	self refresh
]

{ #category : 'announcing' }
NTItemViewPresenter >> whenItemsChangedDo: aBlock [
	"aBlock is evaluated after an item was ticked or unticked."

	changedBlock := aBlock
]

{ #category : 'announcing' }
NTItemViewPresenter >> whenTaskRequestedDo: aBlock [
	"aBlock is evaluated with the task of a double-clicked item."

	taskRequestedBlock := aBlock
]
