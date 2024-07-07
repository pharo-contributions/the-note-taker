"
Presents the note content when a note is selected in the `NtSpNoteIndexPresenter`.

"
Class {
	#name : 'NTSpNoteContentPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'contentPresenter'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'accessing' }
NTSpNoteContentPresenter >> contents: aString [

	contentPresenter textInputText: aString
]

{ #category : 'transmission' }
NTSpNoteContentPresenter >> defaultInputPort [

	^ SpModelPort newPresenter: self
]

{ #category : 'layout' }
NTSpNoteContentPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		add: contentPresenter;
		yourself
]

{ #category : 'accessing' }
NTSpNoteContentPresenter >> editorPresenter [
	"Answer the receiver's <NTMDEditorPresenter>"

	^ contentPresenter
]

{ #category : 'initialization' }
NTSpNoteContentPresenter >> initializePresenters [

	contentPresenter := (self instantiate: NTMDEditorPresenter on: self)
		cleanInput;
		cleanOutput;
		yourself.
]

{ #category : 'accessing' }
NTSpNoteContentPresenter >> selectedNoteTitle [

	^ String streamContents: [ : stream |
		self owner selectedNoteTitle
			ifNotEmpty: [ : title |
				stream
					<< ' - ';
					<< title ]
			ifEmpty: [ String empty ] ]
]

{ #category : 'accessing - model' }
NTSpNoteContentPresenter >> setModel: aNoteObject [ 
	"Private - Set the receiver's content iterating recursively starting from aNode"
	
	"(self editorPresenter canOpenFile: aNoteObject)
		ifTrue: [ aNoteObject openFromPresenter: self ]
		ifFalse: [ aNoteObject newFromPresenter: self ]" 

]
