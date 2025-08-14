"
Presents a table with basic metadata information about saved notes in the system.

"
Class {
	#name : 'SpTaskMainPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'taskFilter',
		'taskList'
	],
	#category : 'TheNoteTaker-Todo-UI-Core',
	#package : 'TheNoteTaker-Todo-UI',
	#tag : 'Core'
}

{ #category : 'initialization' }
SpTaskMainPresenter >> connectPresenters [

	taskFilter whenFilteredItemChangeDo: [ :filteredItems |
		taskList setModel: filteredItems ]
]

{ #category : 'layout' }
SpTaskMainPresenter >> defaultLayout [

	^ SpPanedLayout newLeftToRight
		  add: taskFilter;
		  add: taskList;
		  positionOfSlider: 20 percent;
		  yourself
]

{ #category : 'initialization' }
SpTaskMainPresenter >> initializePresenters [

	taskFilter := self instantiate: SpTaskFilterPresenter on: self application taskContainer.
	
	taskList := self instantiate: SpTaskListPresenter.
]

{ #category : 'initialization' }
SpTaskMainPresenter >> removeTask: aTask [

	self application taskContainer removeTask: aTask
]
