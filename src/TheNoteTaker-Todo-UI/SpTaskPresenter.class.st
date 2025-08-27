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

{ #category : 'accessing' }
SpTaskPresenter >> clickDone [

	doneButton click
]

{ #category : 'accessing' }
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

{ #category : 'accessing' }
SpTaskPresenter >> whenRemovedDo: aBlock [

	removeButton whenActivatedDo: aBlock
]
