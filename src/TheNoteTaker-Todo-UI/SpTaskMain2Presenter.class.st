"
Presents a table with basic metadata information about saved notes in the system.

"
Class {
	#name : 'SpTaskMain2Presenter',
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
SpTaskMain2Presenter >> connectPresenters [

	taskFilter whenFilteredItemChangeDo: [ :filteredItems |
		taskList setModel: filteredItems ]
]

{ #category : 'layout' }
SpTaskMain2Presenter >> defaultLayout [

	^ SpPanedLayout newLeftToRight
		  add: taskFilter;
		  add: taskList;
		  positionOfSlider: 20 percent;
		  yourself
]

{ #category : 'initialization' }
SpTaskMain2Presenter >> initializePresenters [

	taskFilter := self instantiate: SpTaskFilterPresenter on: self application taskContainer.
	
	taskList := self instantiate: SpTaskListPresenter.
]

{ #category : 'initialization' }
SpTaskMain2Presenter >> removeTask: aTask [

	self application taskContainer removeTask: aTask
]
