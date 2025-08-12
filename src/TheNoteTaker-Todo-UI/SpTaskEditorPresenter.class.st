Class {
	#name : 'SpTaskEditorPresenter',
	#superclass : 'SpDialogPresenter',
	#instVars : [
		'task',
		'titleInput',
		'descriptionInput',
		'isRecurrentInput',
		'limitDateInput',
		'tagsInput',
		'validButton'
	],
	#category : 'TheNoteTaker-Todo-UI-Core',
	#package : 'TheNoteTaker-Todo-UI',
	#tag : 'Core'
}

{ #category : 'initialization' }
SpTaskEditorPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: 'Title : ';
		  add: titleInput;
		  add: 'Description : ';
		  add: descriptionInput;
		  add: (SpBoxLayout newLeftToRight
				   add: 'Recurrent : ';
				   add: isRecurrentInput;
				   add: 'limit Date : ';
				   add: limitDateInput);
		  add: tagsInput;
		  add: validButton;
		  yourself
]

{ #category : 'initialization' }
SpTaskEditorPresenter >> initializePresenters [

	titleInput := self newTextInput.
	descriptionInput := self newTextInput.
	isRecurrentInput := self newRadioButton.
	limitDateInput := SpDatePresenter new.
	tagsInput := self newButton label: 'tags'; action: [ self openTagsManager ]; yourself.
	validButton := self newButton
		               label: 'Valid';
		               action: [
				               self save.
				               self delete ]
]

{ #category : 'initialization' }
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

{ #category : 'initialization' }
SpTaskEditorPresenter >> save [

	task title: titleInput text.
	task description: descriptionInput text.
	task isRecurrent: isRecurrentInput isActive.
	task limitDate: limitDateInput date asDateAndTime.
]

{ #category : 'initialization' }
SpTaskEditorPresenter >> task [
	
	^ task
]

{ #category : 'initialization' }
SpTaskEditorPresenter >> task: aTask [
	
	task := aTask.
	titleInput text: task title.
	descriptionInput text: task description.
	isRecurrentInput state: task isRecurrent.
	limitDateInput date: task limitDate.
]
