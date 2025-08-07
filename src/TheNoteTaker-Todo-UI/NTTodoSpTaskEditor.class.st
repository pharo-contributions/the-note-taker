Class {
	#name : 'NTTodoSpTaskEditor',
	#superclass : 'SpPresenter',
	#instVars : [
		'task',
		'titleInput',
		'descriptionInput',
		'isRecurrentInput',
		'limitDateInput',
		'tagsInput',
		'validButton',
		'stateInput'
	],
	#category : 'TheNoteTaker-Todo-UI-Core',
	#package : 'TheNoteTaker-Todo-UI',
	#tag : 'Core'
}

{ #category : 'initialization' }
NTTodoSpTaskEditor >> defaultLayout [

	^ SpBoxLayout newTopToBottom
			add: titleInput;
			add: descriptionInput;
			add: isRecurrentInput ;
			add: limitDateInput ;
			add: stateInput ;
			"add: tagsInput;"
			add: validButton;
			yourself
]

{ #category : 'initialization' }
NTTodoSpTaskEditor >> initializePresenters [

	titleInput := self newTextInput.
	descriptionInput := self newTextInput.
	isRecurrentInput := self newRadioButton.
	limitDateInput := SpDatePresenter new.
	tagsInput := NTSpTagSelectionDialog new.
	validButton := self newButton
		               label: 'Valid';
		               action: [
				               self save.
				               self delete ]
]

{ #category : 'initialization' }
NTTodoSpTaskEditor >> save [

	task title: titleInput text.
	task description: descriptionInput text.
	task isRecurrent: isRecurrentInput isActive.
	task limitDate: limitDateInput date asDateAndTime.
	task state: stateInput selectedItem.
]

{ #category : 'initialization' }
NTTodoSpTaskEditor >> task [
	
	^ task
]

{ #category : 'initialization' }
NTTodoSpTaskEditor >> task: aTask [
	
	task := aTask.
	titleInput text: task title.
	descriptionInput text: task description.
	isRecurrentInput state: task isRecurrent.
	limitDateInput date: task limitDate.
]
