"
He's the taskFilterPresenter.

He has many button for filtering when we click on, like trashTask,DoneTask,todayTask...
We also have a search bar for filter by their title, and a button for filter by their tags like in the NTSpIndexPresenter.

We have a events for do an action when we change the filteredItem with whenFilteredItemChangeDo: 

"
Class {
	#name : 'SpTaskFilterPresenter',
	#superclass : 'SpPresenterWithModel',
	#instVars : [
		'#searchBar',
		'#doneButton',
		'#inBoxButton',
		'#todayButton',
		'#addButton',
		'#lateButton',
		'#trashButton',
		'#filteredItem => ObservableSlot'
	],
	#category : 'TheNoteTaker-Todo-UI-Core',
	#package : 'TheNoteTaker-Todo-UI',
	#tag : 'Core'
}

{ #category : 'adding' }
SpTaskFilterPresenter >> addTask [

	| task |
	task := Task new.
	(SpTaskEditorPresenter newApplication: self application)
		task: task;
		openModalWithParent: self.
	self model addTask: task.
	self filteredItem: self tasks
]

{ #category : 'initialization' }
SpTaskFilterPresenter >> connectPresenters [

	searchBar whenTextChangedDo: [ self filter ].
]

{ #category : 'layout' }
SpTaskFilterPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: searchBar;
		  add: addButton;
		  add: inBoxButton;
		  add: todayButton;
		  add: lateButton;
		  add: doneButton;
		  add: trashButton;
		  yourself
]

{ #category : 'filtering' }
SpTaskFilterPresenter >> filter [

	| filteredItems |
	filteredItems := searchBar text
		                 ifEmpty: [ self tasks ]
		                 ifNotEmpty: [ :pattern |
		                 self model tasksTitleMatching: pattern ].

	self filteredItem: filteredItems
]

{ #category : 'accessing' }
SpTaskFilterPresenter >> filteredItem [

	^ filteredItem
]

{ #category : 'accessing' }
SpTaskFilterPresenter >> filteredItem: anObject [

	filteredItem := anObject
]

{ #category : 'initialization' }
SpTaskFilterPresenter >> initializePresenters [

	self model: self application taskContainer.

	filteredItem := self tasks.

	searchBar := self newTextInput
		             help: 'Create a note by just typing a name';
		             placeholder: 'Type note to search or create';
		             yourself.

	addButton := self newButton
		             label: 'add new';
		             action: [ self addTask ].
	doneButton := self newButton
		              label: 'done';
		              action: [ self filteredItem: self model getDoneTask ].
	inBoxButton := self newButton
		               label: 'In Box';
		               action: [ self filteredItem: self model getInBoxTask ].
	todayButton := self newButton
		               label: 'today';
		               action: [ self filteredItem: self model getTodayTask ].
	lateButton := self newButton
		              label: 'Late';
		              action: [ self filteredItem: self model getLateTask ].
	trashButton := self newButton
		               label: 'Trash';
		               action: [ self filteredItem: self model getTrashTask ]
]

{ #category : 'accessing' }
SpTaskFilterPresenter >> tasks [ 

	^ self model tasks
]

{ #category : 'api - events' }
SpTaskFilterPresenter >> whenFilteredItemChangeDo: aBlock [

	self
		property: #filteredItem
		whenChangedDo: aBlock
]
