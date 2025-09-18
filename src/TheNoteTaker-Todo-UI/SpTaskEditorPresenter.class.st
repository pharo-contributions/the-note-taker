"
represent the task edition window, with field for change the title, the description, the date and other information.
"
Class {
	#name : 'SpTaskEditorPresenter',
	#superclass : 'SpAbstractCancelableMessageDialog',
	#instVars : [
		'task',
		'titleInput',
		'descriptionInput',
		'isRecurrentInput',
		'limitDateInput',
		'tagsInput',
		'validButton',
		'tagsList'
	],
	#category : 'TheNoteTaker-Todo-UI-Core',
	#package : 'TheNoteTaker-Todo-UI',
	#tag : 'Core'
}

{ #category : 'private' }
SpTaskEditorPresenter >> accept [

	task title: titleInput text.
	task description: descriptionInput text.
	task isRecurrent: isRecurrentInput isActive.
	task limitDate: limitDateInput date asDateAndTime.
	
	super accept
]

{ #category : 'layout' }
SpTaskEditorPresenter >> defaultLayout [

	^ SpGridLayout new
		  beRowNotHomogeneous;
		  beColumnHomogeneous;
		  column: 2 expand: true;
		  build: [ :builder |
				  builder
					  add: 'Title :';
					  add: titleInput span: 3 @ 1;
					  nextRow;
					  add: 'Description';
					  add: descriptionInput span: 3 @ 1;
					  nextRow;
					  add: 'IsReccurent';
					  add: isRecurrentInput;
					  nextRow;
					  add: 'limit Date :';
					  add: limitDateInput span: 2 @ 1;
					  nextRow;
					  add: tagsInput;
					  add: tagsList  span: 3 @ 5];
		  yourself
]

{ #category : 'layout' }
SpTaskEditorPresenter >> defaultLayout2 [

	^ SpBoxLayout newTopToBottom
		  add: (SpBoxLayout newLeftToRight
				   add: 'Title: ';
				   add: titleInput;
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newLeftToRight
				   add: 'Description : ';
				   add: descriptionInput;
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newLeftToRight
				   add: 'Recurrent : ';
				   add: isRecurrentInput;
				   add: 'limit Date : ';
				   add: limitDateInput)
		  expand: false;
		  add: tagsInput expand: false;
		  yourself
]

{ #category : 'accessing' }
SpTaskEditorPresenter >> defaultTitle [
	
	^ 'Tags Manager'
]

{ #category : 'initialization' }
SpTaskEditorPresenter >> initializePresenters [

	super initializePresenters.

	titleInput := self newTextInput.
	descriptionInput := self newText.
	descriptionInput text: 'Toto'.
	isRecurrentInput := self newCheckBox.
	limitDateInput := SpDatePresenter new.
	tagsInput := self newButton
		             label: 'tags';
		             action: [ self openTagsManager ];
		             yourself.
	tagsList := self newList.
]

{ #category : 'initialization' }
SpTaskEditorPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter whenOpenedDo: [ titleInput takeKeyboardFocus ]
]

{ #category : 'opening' }
SpTaskEditorPresenter >> openTagsManager [

	(SpTaskTagSelectionDialog newApplication: self application)
		allowTagCreation;
		title: 'tag name';
		items:
			(self application taskContainer tags asOrderedCollection collect: [ :each |
					 each tagName ]);
		display: #asString;
		onAccept: [ :dialog |
				dialog presenter selectedItems do: [ :tagName |
							| tag |
							tag := self application taskContainer ensureTagNamed: tagName.
							tag addTask: task ] ];
		openModalWithParent: self window
]

{ #category : 'accessing' }
SpTaskEditorPresenter >> task [
	
	^ task
]

{ #category : 'accessing' }
SpTaskEditorPresenter >> task: aTask [

	task := aTask.
	titleInput text: task title.
	descriptionInput text: task description.
	isRecurrentInput state: task isRecurrent.
	limitDateInput date: task limitDate.
	tagsList
		items: task tags asOrderedCollection ;
		display: [ :tag | tag tagName ]
]
