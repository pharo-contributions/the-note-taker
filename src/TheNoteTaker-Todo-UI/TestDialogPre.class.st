Class {
	#name : 'TestDialogPre',
	#superclass : 'SpAbstractCancelableMessageDialog',
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

{ #category : 'layout' }
TestDialogPre >> defaultLayout [

	^ SpGridLayout new
		  add: descriptionInput atPoint: 1 @ 1 span: 1 @ 1;
		  yourself
]

{ #category : 'accessing' }
TestDialogPre >> defaultTitle [
	^ 'Test'
]

{ #category : 'initialization' }
TestDialogPre >> initializePresenters [

	super initializePresenters.

	descriptionInput := self newTextInput
]
