Class {
	#name : 'SpTaskListPresenter',
	#superclass : 'SpPresenterWithModel',
	#instVars : [
		'componentList',
		'selectAllbutton',
		'doneSelectedButton',
		'trashSelectedButton'
	],
	#category : 'TheNoteTaker-Todo-UI-Core',
	#package : 'TheNoteTaker-Todo-UI',
	#tag : 'Core'
}

{ #category : 'initialization' }
SpTaskListPresenter >> connectPresenters [

	self whenSelectedItemChangedDo: [ :taskPresenter |
			taskPresenter ifNotNil: [
					(SpTaskEditorPresenter newApplication: self application)
						task: taskPresenter task;
						onAccept: [ ];
						onCancel: [ ];
						openModalWithParent: self ].
			self updatePresenter ]
]

{ #category : 'layout' }
SpTaskListPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: (SpBoxLayout newLeftToRight
				   add: selectAllbutton;
				   add: doneSelectedButton;
				   add: trashSelectedButton;
				   yourself) expand: false;
		  add: componentList;
		  yourself
]

{ #category : 'initialization' }
SpTaskListPresenter >> initializePresenters [

	componentList := self newComponentList beMultipleSelection.

	selectAllbutton := self newButton
		                   label: 'Select All';
		                   action: [ componentList selectAll ].
	doneSelectedButton := self newButton
		                      label: 'Make done all selected';
		                      action: [
			                      componentList selectedItems do: [ :each |
					                      each clickDone ] ].
	trashSelectedButton := self newButton
		                       label: 'Make trash all selected';
		                       action: [
			                       componentList selectedItems do: [ :each |
					                       each clickRemove ] ]
]

{ #category : 'accessing' }
SpTaskListPresenter >> items [
	"Answer a <Collection> of notes"

	^ componentList items collect: [ :each | each task ]
]

{ #category : 'api' }
SpTaskListPresenter >> items: aCollection [

	aCollection ifNil: [ ^ self ].

	componentList presenters: (aCollection collect: [ :each |
				 | taskPresenter |
				 taskPresenter := SpTaskPresenter new task: each.
				 taskPresenter whenRemovedDo: [
						 self owner removeTask: each.
						 componentList presenters: (componentList presenters
								  remove: taskPresenter;
								  yourself) ] ])
]

{ #category : 'initialization' }
SpTaskListPresenter >> modelChanged [

	self model ifNotNil: [ self items: self model ]
]

{ #category : 'initialization' }
SpTaskListPresenter >> whenSelectedItemChangedDo: aBlock [
	"Inform when an item was selected (a real object in the items list).
	 `aBlock` receives one argument (the new selected element)"

	componentList whenSelectionChangedDo: [ :selection |
			selection selectedItems size = 1 ifTrue: [
				aBlock value: selection selectedItem ] ]
]
