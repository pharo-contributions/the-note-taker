"
Presents a table with basic metadata information about saved notes in the system.

"
Class {
	#name : 'NTTodoSpNoteIndexPresenter',
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
NTTodoSpNoteIndexPresenter >> addTask [

	| task |
	task := NTTodo new.
	(NTTodoSpTaskEditor newApplication: self application) task: task; openModalWithParent: self.
	self model addTask: task.
	self updatePresenter
]

{ #category : 'initialization' }
NTTodoSpNoteIndexPresenter >> connectPresenters [

	searchBar whenTextChangedDo: [ self filter ].
	
	tagsList whenSelectionChangedDo: [ :tag |  self showTaskForTag: tagsList selectedItem ].

	componentList whenSelectedItemChangedDo: [ :taskPresenter |
			taskPresenter ifNotNil: [
					(NTTodoSpTaskEditor newApplication: self application)
						task: taskPresenter task;
						openModalWithParent: self ]. self updatePresenter ]
]

{ #category : 'layout' }
NTTodoSpNoteIndexPresenter >> defaultLayout [

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
NTTodoSpNoteIndexPresenter >> filter [

	| filteredItems |
	filteredItems := searchBar text
		                 ifEmpty: [ self tasks ]
		                 ifNotEmpty: [ :pattern |
		                 self model tasksTitleMatching: pattern ].

	self items: filteredItems
]

{ #category : 'initialization' }
NTTodoSpNoteIndexPresenter >> initializePresenters [

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
NTTodoSpNoteIndexPresenter >> items [
	"Answer a <Collection> of notes"

	^ componentList items collect: [ :each | each note ]
]

{ #category : 'accessing' }
NTTodoSpNoteIndexPresenter >> items: aCollection [
	"componentList items: aCollection."
	
	aCollection ifNil: [ ^ self ].

	componentList presenters:
		(aCollection collect: [ :each | NTTodoPresenter new task: each ])
]

{ #category : 'initialization' }
NTTodoSpNoteIndexPresenter >> modelChanged [

	self model ifNotNil: [
			self items: self tasks.
			"tagsList items: self model tags" ]
]

{ #category : 'initialization' }
NTTodoSpNoteIndexPresenter >> showDoneTasks [

	self items: self model getDoneTask
]

{ #category : 'initialization' }
NTTodoSpNoteIndexPresenter >> showInBoxTasks [

	self items: self model getInBoxTask
]

{ #category : 'initialization' }
NTTodoSpNoteIndexPresenter >> showLateTasks [

	self items: self model getLateTask
]

{ #category : 'initialization' }
NTTodoSpNoteIndexPresenter >> showTaskForTag: aTag [

	self items: (self model getTaskForTag: aTag)
]

{ #category : 'initialization' }
NTTodoSpNoteIndexPresenter >> showTodayTasks [

	self items: self model getTodayTask
]

{ #category : 'initialization' }
NTTodoSpNoteIndexPresenter >> showTrashTasks [

	self items: self model getTrashTask
]

{ #category : 'initialization' }
NTTodoSpNoteIndexPresenter >> showWeekTasks [

	self items: self model getWeekTask
]

{ #category : 'filtering' }
NTTodoSpNoteIndexPresenter >> tasks [ 

	^ self model tasks
]
