"
Represent a Task presenter use by the taskListPresenter.

he has a task, who is showing in the middle of the presenter. We have a done button and a remove button.

The clickDone and clickRemove are used in test for simulating a click on this button.

We have event like whenRemovedDo: aBlock for do an action when the task is removed
(maybe add an event for click on Done button)
"
Class {
	#name : 'SpTaskPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'task',
		'doneButton',
		'removeButton'
	],
	#category : 'TheNoteTaker-Todo-UI-Core',
	#package : 'TheNoteTaker-Todo-UI',
	#tag : 'Core'
}

{ #category : 'simulating' }
SpTaskPresenter >> clickDone [

	doneButton click
]

{ #category : 'simulating' }
SpTaskPresenter >> clickRemove [

	removeButton click 
]

{ #category : 'layout' }
SpTaskPresenter >> defaultLayout [

	^ SpBoxLayout new beLeftToRight
		  add: doneButton expand: false;
		  add: (SpBoxLayout new beTopToBottom
				   add: task title;
				   add: task limitDate;
				   yourself);
		  add: removeButton expand: false;
		  yourself
]

{ #category : 'initialization' }
SpTaskPresenter >> initializePresenters [

	doneButton := self newButton
		              icon: (self iconNamed: #smallOk);
		              label: 'Done';
		              action: [ task isDone: true ].
	removeButton := self newButton
		                icon: (self iconNamed: #smallCancel);
		                label: 'Remove'
]

{ #category : 'accessing' }
SpTaskPresenter >> task [ 

	^ task
]

{ #category : 'accessing' }
SpTaskPresenter >> task: aTask [

	task := aTask 
]

{ #category : 'api - events' }
SpTaskPresenter >> whenRemovedDo: aBlock [

	removeButton whenActivatedDo: aBlock
]
