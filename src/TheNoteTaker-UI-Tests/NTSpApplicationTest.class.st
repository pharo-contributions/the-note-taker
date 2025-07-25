Class {
	#name : 'NTSpApplicationTest',
	#superclass : 'NTSpTestCase',
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'tests' }
NTSpApplicationTest >> testSearchNoteByName [

	| note1 note3 |
	note1 := noteContainer addNoteNamed: 'Test'.
	noteContainer addNoteNamed: 'Test2'.
	note3 :=noteContainer addNoteNamed: 'Test3'.
	
	self assert: (app noteNamed: note1 fileName) equals: note1.
	self assert: (app noteNamed: note3 fileName) equals: note3.
]
