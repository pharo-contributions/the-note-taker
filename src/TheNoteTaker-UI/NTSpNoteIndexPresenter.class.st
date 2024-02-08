Class {
	#name : 'NTSpNoteIndexPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'notesIndexPresenter'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'layout' }
NTSpNoteIndexPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom 
		add: notesIndexPresenter;
		yourself.
]

{ #category : 'initialization' }
NTSpNoteIndexPresenter >> initializePresenters [

	notesIndexPresenter := self newTable
		addColumn: (SpCompositeTableColumn 
			title: 'Title';
			evaluated: #title;
			yourself);
		addColumn: (SpStringTableColumn new
			title: 'Tags';
			evaluated: #tags;
			yourself);
		addColumn: (SpStringTableColumn new
		   title: 'Date';
			evaluated: #creationDate;
			beNotExpandable;			
			yourself);
		yourself
]
