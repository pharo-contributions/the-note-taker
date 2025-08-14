"
Presents a table with basic metadata information about saved notes in the system.

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

{ #category : 'initialization' }
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
		  add: doneButton;
		  add: inBoxButton;
		  add: todayButton;
		  add: lateButton;
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
		              action: [ self showDoneTasks ].
	inBoxButton := self newButton
		               label: 'In Box';
		               action: [ self showInBoxTasks ].
	todayButton := self newButton
		               label: 'today';
		               action: [ self showTodayTasks ].
	lateButton := self newButton
		              label: 'Late';
		              action: [ self showLateTasks ].
	trashButton := self newButton
		               label: 'Trash';
		               action: [ self showTrashTasks ]
]

{ #category : 'initialization' }
SpTaskFilterPresenter >> showDoneTasks [

	self filteredItem: self model getDoneTask
]

{ #category : 'initialization' }
SpTaskFilterPresenter >> showInBoxTasks [

	self filteredItem: self model getInBoxTask
]

{ #category : 'initialization' }
SpTaskFilterPresenter >> showLateTasks [

	self filteredItem: self model getLateTask
]

{ #category : 'initialization' }
SpTaskFilterPresenter >> showTodayTasks [

	self filteredItem: self model getTodayTask
]

{ #category : 'initialization' }
SpTaskFilterPresenter >> showTrashTasks [

	self filteredItem: self model getTrashTask
]

{ #category : 'initialization' }
SpTaskFilterPresenter >> showWeekTasks [

	self filteredItem: self model getWeekTask
]

{ #category : 'filtering' }
SpTaskFilterPresenter >> tasks [ 

	^ self model tasks
]

{ #category : 'filtering' }
SpTaskFilterPresenter >> whenFilteredItemChangeDo: aBlock [

	self
		property: #filteredItem
		whenChangedDo: aBlock
]
