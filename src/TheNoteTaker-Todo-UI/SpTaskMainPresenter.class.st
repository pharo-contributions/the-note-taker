"
Presents a table with basic metadata information about saved notes in the system.

"
Class {
	#name : 'SpTaskMainPresenter',
	#superclass : 'SpPresenterWithModel',
	#instVars : [
		'componentList',
		'searchBar',
		'doneButton',
		'inBoxButton',
		'todayButton',
		'addButton',
		'weekButton',
		'lateButton',
		'trashButton',
		'tagsList'
	],
	#category : 'TheNoteTaker-Todo-UI-Core',
	#package : 'TheNoteTaker-Todo-UI',
	#tag : 'Core'
}

{ #category : 'initialization' }
SpTaskMainPresenter >> addTask [

	| task |
	task := Task new.
	(SpTaskEditorPresenter newApplication: self application) task: task; openModalWithParent: self.
	self model addTask: task.
	self updatePresenter
]

{ #category : 'initialization' }
SpTaskMainPresenter >> connectPresenters [

	searchBar whenTextChangedDo: [ self filter ].

	tagsList whenSelectionChangedDo: [ :tag |
		self showTaskForTag: tagsList selectedItem ].

	componentList whenSelectedItemChangedDo: [ :taskPresenter |
			taskPresenter ifNotNil: [
					(SpTaskEditorPresenter newApplication: self application)
						task: taskPresenter task;
						onAccept: [  ];
						onCancel: [  ];
						openModalWithParent: self ].
			self updatePresenter ]
]

{ #category : 'layout' }
SpTaskMainPresenter >> defaultLayout [

	^ SpBoxLayout newLeftToRight
		  add: (SpBoxLayout newTopToBottom
				   add: searchBar;
				   add: addButton;
				   add: doneButton;
				   add: inBoxButton;
				   add: todayButton;
				   add: weekButton;
				   add: lateButton;
				   add: trashButton;
				   add: 'Tags List';
				   add: tagsList;
				   yourself);
		  add: componentList;
		  yourself
]

{ #category : 'filtering' }
SpTaskMainPresenter >> filter [

	| filteredItems |
	filteredItems := searchBar text
		                 ifEmpty: [ self tasks ]
		                 ifNotEmpty: [ :pattern |
		                 self model tasksTitleMatching: pattern ].

	self items: filteredItems
]

{ #category : 'initialization' }
SpTaskMainPresenter >> initializePresenters [

	self model: self application taskContainer.

	searchBar := self newTextInput
		             help: 'Create a note by just typing a name';
		             placeholder: 'Type note to search or create';
		             yourself.

	componentList := self instantiate: SpComponentListPresenter.
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
	weekButton := self newButton
		              label: 'Week';
		              action: [ self showWeekTasks ].
	lateButton := self newButton
		              label: 'Late';
		              action: [ self showLateTasks ].
	trashButton := self newButton
		               label: 'Trash';
		               action: [ self showTrashTasks ].

	tagsList := SpEasyListViewPresenter new items: self model tags
]

{ #category : 'accessing' }
SpTaskMainPresenter >> items [
	"Answer a <Collection> of notes"

	^ componentList items collect: [ :each | each note ]
]

{ #category : 'accessing' }
SpTaskMainPresenter >> items: aCollection [
	"componentList items: aCollection."
	
	aCollection ifNil: [ ^ self ].

	componentList presenters:
		(aCollection collect: [ :each | SpTaskPresenter new task: each ])
]

{ #category : 'initialization' }
SpTaskMainPresenter >> modelChanged [

	self model ifNotNil: [
			self items: self tasks.
			"tagsList items: self model tags" ]
]

{ #category : 'initialization' }
SpTaskMainPresenter >> showDoneTasks [

	self items: self model getDoneTask
]

{ #category : 'initialization' }
SpTaskMainPresenter >> showInBoxTasks [

	self items: self model getInBoxTask
]

{ #category : 'initialization' }
SpTaskMainPresenter >> showLateTasks [

	self items: self model getLateTask
]

{ #category : 'initialization' }
SpTaskMainPresenter >> showTaskForTag: aTag [

	self items: (self model getTaskForTag: aTag)
]

{ #category : 'initialization' }
SpTaskMainPresenter >> showTodayTasks [

	self items: self model getTodayTask
]

{ #category : 'initialization' }
SpTaskMainPresenter >> showTrashTasks [

	self items: self model getTrashTask
]

{ #category : 'initialization' }
SpTaskMainPresenter >> showWeekTasks [

	self items: self model getWeekTask
]

{ #category : 'filtering' }
SpTaskMainPresenter >> tasks [ 

	^ self model tasks
]
