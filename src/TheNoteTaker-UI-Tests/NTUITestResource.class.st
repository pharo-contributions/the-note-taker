Class {
	#name : 'NTUITestResource',
	#superclass : 'TestResource',
	#instVars : [
		'note1',
		'note2',
		'note3',
		'tag1',
		'tag2',
		'tag3'
	],
	#category : 'TheNoteTaker-UI-Tests-Support-Resources',
	#package : 'TheNoteTaker-UI-Tests',
	#tag : 'Support-Resources'
}

{ #category : 'adding' }
NTUITestResource >> addingNotesAndTagsTo: aNoteContainer [

	| notesCollection tagsCollection |
	notesCollection := OrderedCollection new
		                   add: note1;
		                   add: note2;
		                   add: note3;
		                   yourself.
	tagsCollection := OrderedCollection new
		                  add: tag1;
		                  add: tag2;
		                  add: tag3;
		                  yourself.

	aNoteContainer
		notes: notesCollection;
		tags: tagsCollection
]

{ #category : 'accessing' }
NTUITestResource >> getNote1 [

	^ note1
]

{ #category : 'accessing' }
NTUITestResource >> getNote2 [

	^ note2
]

{ #category : 'accessing' }
NTUITestResource >> getNote3 [

	^ note3
]

{ #category : 'accessing' }
NTUITestResource >> getTag1 [

	^ tag1
]

{ #category : 'accessing' }
NTUITestResource >> getTag2 [

	^ tag2
]

{ #category : 'accessing' }
NTUITestResource >> getTag3 [

	^ tag3
]

{ #category : 'initialization' }
NTUITestResource >> initialize [

	super initialize.

	note1 := NTNote content: 'note1'.
	note2 := NTNote content: 'note2'.
	note3 := NTNote content: 'note3'.

	tag1 := NTTag newNamed: 'tag1'.
	tag2 := NTTag newNamed: 'tag2'.
	tag3 := NTTag newNamed: 'tag3'.

	note1 addTag: tag1.
	note1 addTag: tag3.
	note2 addTag: tag2
]
