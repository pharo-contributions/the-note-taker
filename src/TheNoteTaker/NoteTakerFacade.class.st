Class {
	#name : 'NoteTakerFacade',
	#superclass : 'Object',
	#instVars : [
		'notes'
	],
	#category : 'TheNoteTaker-Core',
	#package : 'TheNoteTaker',
	#tag : 'Core'
}

{ #category : 'adding' }
NoteTakerFacade >> addNoteNamed: aString [
	"Add a new note with title aString to the receiver's notes. Answer the receiver"
	
	self notes 
		at: aString 
		put: (self newNoteNamed: aString)
]

{ #category : 'testing' }
NoteTakerFacade >> hasNoteNamed: aString [
	"Answer <true> if the receiver includes a note with title aString"

	^ self notes includesKey: aString
]

{ #category : 'testing' }
NoteTakerFacade >> hasNotes [
	"Answer <true> if the receiver includes any note"
	
	^ self notes isNotEmpty
]

{ #category : 'initialization' }
NoteTakerFacade >> initialize [

	super initialize.
	self notes: SmallDictionary new.
]

{ #category : 'testing' }
NoteTakerFacade >> isValidNote: aString [ 
	"Answer <true> if aString is a valid note title, i.e. 
		Non-empty, and not already present"

	(aString notNil and: [ aString notEmpty ])
		ifTrue: [ ^ (self hasNoteNamed: aString trimBoth) not ].
	^ false
]

{ #category : 'adding' }
NoteTakerFacade >> newNoteNamed: aNoteName [

	^ NTNoteObject named: aNoteName
]

{ #category : 'accessing' }
NoteTakerFacade >> noteNamed: aString [
	"Answer the receiver's <NTNoteObject>"
	
	^ self notes at: aString
]

{ #category : 'accessing' }
NoteTakerFacade >> notes [
	"Answer the receiver's <Collection> of <NTNoteObject>"

	^ notes
]

{ #category : 'accessing' }
NoteTakerFacade >> notes: aCollection [ 
	notes := aCollection
]

{ #category : 'accessing' }
NoteTakerFacade >> notesCount [
	"Answer an <Integer> representing how many notes the receiver includes"
	
	^ self notes size
]

{ #category : 'removing' }
NoteTakerFacade >> removeNoteNamed: aString [
	"Remove the note with title aString in the receiver's notes. Answer the receiver"
	
	self notes removeKey: aString
]
