Class {
	#name : 'NTUITestResource',
	#superclass : 'TestResource',
	#instVars : [
		'noteContainer'
	],
	#category : 'TheNoteTaker-UI-Tests-Support-Resources',
	#package : 'TheNoteTaker-UI-Tests',
	#tag : 'Support-Resources'
}

{ #category : 'as yet unclassified' }
NTUITestResource >> generateNoteAndTagsTo: aNoteContainer [

	| note1 note2 note3 tag1 tag2 tag3 |
	note1 := aNoteContainer addNoteNamed: 'note1'.
	note2 := aNoteContainer addNoteNamed: 'note2'.
	note3 := aNoteContainer addNoteNamed: 'note3'.

	tag1 := aNoteContainer addTagNamed: 'tag1'.
	tag2 := aNoteContainer addTagNamed: 'tag2'.
	tag3 := aNoteContainer addTagNamed: 'tag3'.

	note1 addTag: tag1.
	note1 addTag: tag3.
	note2 addTag: tag2.
	
noteContainer := aNoteContainer
]

{ #category : 'accessing' }
NTUITestResource >> getNote1 [

	^ noteContainer noteTitled: 'note1'
]

{ #category : 'accessing' }
NTUITestResource >> getNote2 [

	^ noteContainer noteTitled: 'note2'
]

{ #category : 'accessing' }
NTUITestResource >> getNote3 [

	^ noteContainer noteTitled: 'note3'
]

{ #category : 'accessing' }
NTUITestResource >> getTag1 [

	^ noteContainer tagNamed: 'tag1'
]

{ #category : 'accessing' }
NTUITestResource >> getTag2 [

	^ noteContainer tagNamed: 'tag2'
]

{ #category : 'accessing' }
NTUITestResource >> getTag3 [

	^ noteContainer tagNamed: 'tag3'
]
