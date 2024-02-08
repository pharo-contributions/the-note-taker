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
		addColumn: (SpStringTableColumn new
			title: 'Title';
			sortFunction: #yourself ascending;			
			evaluated: #title;
			yourself);
		addColumn: (SpStringTableColumn new
			title: 'Tags';
			sortFunction: #yourself ascending;			
			evaluated: #tags;
			yourself);
		addColumn: (SpStringTableColumn new
		   title: 'Date';
			sortFunction: #yourself ascending;		
			evaluated: #creationDate;
			yourself);
		yourself
]
