Class {
	#name : 'NTTestResource',
	#superclass : 'TestResource',
	#instVars : [
		'note1',
		'note2',
		'note3',
		'tag1',
		'tag2',
		'tag3'
	],
	#category : 'TheNoteTaker-Tests-Support-Resources',
	#package : 'TheNoteTaker-Tests',
	#tag : 'Support-Resources'
}

{ #category : 'adding' }
NTTestResource >> addingNotesAndTagsTo: aNoteContainer [

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
		rawTags: tagsCollection
]

{ #category : 'accessing' }
NTTestResource >> getNote1 [

	^ note1
]

{ #category : 'accessing' }
NTTestResource >> getNote2 [

	^ note2
]

{ #category : 'accessing' }
NTTestResource >> getNote3 [

	^ note3
]

{ #category : 'accessing' }
NTTestResource >> getTag1 [

	^ tag1
]

{ #category : 'accessing' }
NTTestResource >> getTag2 [

	^ tag2
]

{ #category : 'accessing' }
NTTestResource >> getTag3 [

	^ tag3
]

{ #category : 'initialization' }
NTTestResource >> initialize [

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
