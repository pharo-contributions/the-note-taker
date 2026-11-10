"
I am the List tab of a task: a table of its items with a checkbox, a field to add an item (Enter), Remove, Up and Down buttons, and the detail of the selected item.

## Responsibility:

- I show the items in their order with their done state, title and annotations.
- I tick and untick items, add an item (Enter in the field), remove the selected one and move it up or down.
- I tell my owner after every change, so the task is saved.

## Collaborators: 

- `NTTask`: my model; its items are the rows.
- `NTTaskItemPresenter`: edits the selected item.
- `NTTaskEditorPresenter`: my owner, saves the task when I change.

## Public API and Key Messages

- `whenItemsChangedDo: aBlock`
- `addItemTitled:`, `toggle: anItem`, `removeSelectedItem`, `moveSelectedItemUp`, `moveSelectedItemDown`
- `selectItem:`, `selectedItem`

See `NTTaskItemsPresenter class >> #exampleOnTask`.

## Internal Representation

- `table`: an `SpTablePresenter` with a checkbox column, an editable title column and an annotations column (without `@done` and `@created`).
- `changedBlock`: evaluated after each change.
"
Class {
	#name : 'NTTaskItemsPresenter',
	#superclass : 'SpPresenterWithModel',
	#instVars : [
		'table',
		'newItemInput',
		'removeButton',
		'upButton',
		'downButton',
		'itemPresenter',
		'changedBlock'
	],
	#category : 'TheNoteTaker-Tasks-UI',
	#package : 'TheNoteTaker-Tasks-UI'
}

{ #category : 'examples' }
NTTaskItemsPresenter class >> exampleOnTask [

	<sampleInstance>
	^ self newApplication: NTTasksApplication new model: NTTask examplePharoRelease
]

{ #category : 'actions' }
NTTaskItemsPresenter >> addItemFromInput [

	(self addItemTitled: newItemInput text) ifNotNil: [ newItemInput text: '' ]
]

{ #category : 'actions' }
NTTaskItemsPresenter >> addItemTitled: aString [
	"Add an item at the end of the task and select it. Answer it, or nil when the title is empty."

	| title item |
	title := aString asString trimBoth.
	(title isEmpty or: [ self model isNil ]) ifTrue: [ ^ nil ].
	item := self model addItemTitled: title on: Date today.
	self refreshTable.
	self selectItem: item.
	self notifyChanged.
	^ item
]

{ #category : 'private' }
NTTaskItemsPresenter >> annotationsStringOf: anItem [

	^ anItem displayAnnotations
]

{ #category : 'initialization' }
NTTaskItemsPresenter >> connectPresenters [

	newItemInput whenSubmitDo: [ :text | self addItemFromInput ].
	table whenSelectionChangedDo: [ :selection | itemPresenter model: selection selectedItem ].
	itemPresenter whenItemChangedDo: [
			table refresh.
			self notifyChanged ]
]

{ #category : 'layout' }
NTTaskItemsPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 4;
				   add: newItemInput;
				   add: removeButton expand: false;
				   add: upButton expand: false;
				   add: downButton expand: false;
				   yourself)
		  expand: false;
		  add: (SpPanedLayout newLeftToRight
				   positionOfSlider: 60 percent;
				   add: table;
				   add: itemPresenter;
				   yourself);
		  yourself
]

{ #category : 'initialization' }
NTTaskItemsPresenter >> initializePresenters [

	changedBlock := [ ].
	table := self newItemsTable.
	newItemInput := self newTextInput
		                placeholder: 'New item, then Enter';
		                yourself.
	removeButton := self newButtonLabeled: 'Remove' action: [ self removeSelectedItem ].
	upButton := self newButtonLabeled: 'Up' action: [ self moveSelectedItemUp ].
	downButton := self newButtonLabeled: 'Down' action: [ self moveSelectedItemDown ].
	itemPresenter := self instantiate: NTTaskItemPresenter
]

{ #category : 'accessing' }
NTTaskItemsPresenter >> itemPresenter [

	^ itemPresenter
]

{ #category : 'initialization' }
NTTaskItemsPresenter >> modelChanged [

	self updatePresenter
]

{ #category : 'private' }
NTTaskItemsPresenter >> moveSelectedItemBy: aDelta [

	| item index |
	item := self selectedItem ifNil: [ ^ self ].
	index := (self model items indexOf: item) + aDelta.
	(index between: 1 and: self model items size) ifFalse: [ ^ self ].
	self model moveItem: item to: index.
	self refreshTable.
	self selectItem: item.
	self notifyChanged
]

{ #category : 'actions' }
NTTaskItemsPresenter >> moveSelectedItemDown [

	self moveSelectedItemBy: 1
]

{ #category : 'actions' }
NTTaskItemsPresenter >> moveSelectedItemUp [

	self moveSelectedItemBy: -1
]

{ #category : 'initialization' }
NTTaskItemsPresenter >> newButtonLabeled: aString action: aBlock [

	^ self newButton
		  label: aString;
		  action: aBlock;
		  yourself
]

{ #category : 'initialization' }
NTTaskItemsPresenter >> newDoneColumn [

	^ (SpCheckBoxTableColumn evaluated: [ :item | item isDone ])
		  onActivation: [ :item | self toggle: item ];
		  onDeactivation: [ :item | self toggle: item ];
		  width: 30;
		  yourself
]

{ #category : 'accessing' }
NTTaskItemsPresenter >> newItemInput [

	^ newItemInput
]

{ #category : 'initialization' }
NTTaskItemsPresenter >> newItemsTable [
	"A checkbox column to tick items, an editable title column and the other annotations."

	^ self newTable
		  addColumn: self newDoneColumn;
		  addColumn: self newTitleColumn;
		  addColumn: (SpStringTableColumn title: 'Keys and tags' evaluated: [ :item | self annotationsStringOf: item ]);
		  yourself
]

{ #category : 'initialization' }
NTTaskItemsPresenter >> newTitleColumn [

	^ (SpStringTableColumn title: 'Item' evaluated: [ :item | item title ])
		  beEditable;
		  onAcceptEdition: [ :item :text | self rename: item to: text ];
		  yourself
]

{ #category : 'private' }
NTTaskItemsPresenter >> notifyChanged [
	"Tell the owner the task changed, so it is saved."

	changedBlock value
]

{ #category : 'private' }
NTTaskItemsPresenter >> refreshTable [

	table items: self model items.
	table refresh
]

{ #category : 'actions' }
NTTaskItemsPresenter >> removeSelectedItem [

	self selectedItem ifNil: [ ^ self ] ifNotNil: [ :item |
			self model removeItem: item.
			self refreshTable.
			itemPresenter model: nil.
			self notifyChanged ]
]

{ #category : 'actions' }
NTTaskItemsPresenter >> rename: anItem to: aString [

	| title |
	title := aString asString trimBoth.
	title ifEmpty: [ ^ self ].
	anItem title: title.
	self refreshTable.
	self notifyChanged
]

{ #category : 'accessing' }
NTTaskItemsPresenter >> selectItem: anItem [

	table selectItem: anItem
]

{ #category : 'accessing' }
NTTaskItemsPresenter >> selectedItem [

	^ table selectedItem
]

{ #category : 'accessing' }
NTTaskItemsPresenter >> table [

	^ table
]

{ #category : 'actions' }
NTTaskItemsPresenter >> toggle: anItem [
	"Tick or untick anItem; ticking records the @done date."

	anItem isDone
		ifTrue: [ anItem markUndone ]
		ifFalse: [ anItem markDoneOn: Date today ].
	self refreshTable.
	self notifyChanged
]

{ #category : 'updating' }
NTTaskItemsPresenter >> updatePresenter [

	table items: (self model ifNil: [ #(  ) ] ifNotNil: [ :task | task items ]).
	itemPresenter model: nil
]

{ #category : 'announcing' }
NTTaskItemsPresenter >> whenItemsChangedDo: aBlock [

	changedBlock := aBlock
]
