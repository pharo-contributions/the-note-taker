"
Represents a singleton pattern implementation for managing a centralized instance of `NTNoteObject` notes container.

The singleton ensures that there is only one instance of the container throughout the application's lifecycle, providing global access to the collection of notes. It is useful for scenarios where a single instance of a class needs to be shared and accessed globally across multiple parts of the application.

## Usage

To access the unique instance of the Notes container, use the class method 'uniqueInstance'. For example:

```
| notesContainer |
notesContainer := NTSingleton uniqueInstance.
```

### Responsibilities

- Providing a centralized and globally accessible instance of Notes.
- Ensuring that only one instance of the notes container exists within the application.

Note: It is recommended to use the `uniqueInstance` method to access the singleton rather than instantiating it directly.

"
Class {
	#name : 'NTContainer',
	#superclass : 'Object',
	#instVars : [
		'notes',
		'tags'
	],
	#category : 'TheNoteTaker-Core',
	#package : 'TheNoteTaker',
	#tag : 'Core'
}

{ #category : 'adding - notes' }
NTContainer >> addNote: aNTNoteObject [

	^ self notes add: aNTNoteObject
]

{ #category : 'adding - notes' }
NTContainer >> addNoteFromFileReference: aFileReference [
	"Add a new note with title aString to the receiver's notes. Answer the receiver"

	| newNote |
	newNote := self notes add:
		           (NTNoteObject newFromFileReference: aFileReference).
	newNote tagsString ifNotNil: [
			(newNote tagsString substrings: ',') do: [ :each |
				(self tagNamed: each) addNote: newNote ] ].

	^ newNote
]

{ #category : 'adding - notes' }
NTContainer >> addNoteNamed: aString [
	"Add a new empty note with title aString to the receiver's notes. Answer the receiver"
	
	^ self notes add: ( NTNoteObject named: aString)
]

{ #category : 'adding - tags' }
NTContainer >> addTagNamed: aString [
	"Add a new empty note with title aString to the receiver's notes. Answer the receiver"

	^ self tags add: (NTTag newNamed: aString)
]

{ #category : 'testing' }
NTContainer >> hasNoteNamed: aString [
	"Answer <true> if the receiver includes a note with title aString"

	^ self notes anySatisfy: [ : note | note fileName = aString ]
]

{ #category : 'testing' }
NTContainer >> hasNotes [
	"Answer <true> if the receiver includes any note"
	
	^ self notes isNotEmpty
]

{ #category : 'initialization' }
NTContainer >> initialize [

	super initialize.
	self notes: OrderedCollection new.
	self tags: OrderedCollection new
]

{ #category : 'accessing - notes' }
NTContainer >> noteNamed: aString [
	"Answer the first <NTNoteObject> matching aString in its name"
	
	^ self notes detect: [ : n | n fileName = aString ]
]

{ #category : 'accessing - notes' }
NTContainer >> noteTitled: aString [
	"Answer the first <NTNoteObject> matching aString in its name"

	^ self notes detect: [ :n | n title = aString ]
]

{ #category : 'accessing - notes' }
NTContainer >> notes [
	"Answer the receiver's <Collection> of <NTNoteObject>"

	^ notes
]

{ #category : 'accessing - notes' }
NTContainer >> notes: aCollection [ 
	notes := aCollection
]

{ #category : 'accessing - tags' }
NTContainer >> notes: aNotesCollection withTag: aTag [

	^ aNotesCollection select: [ :n | n tags includes: aTag ]
]

{ #category : 'accessing - tags' }
NTContainer >> notes: aNotesCollection withTags: aTagsCollection [
	
	| noteCollection |
	
	noteCollection := aNotesCollection.
	aTagsCollection do: [ :tag | noteCollection := self notes: noteCollection withTag: tag ]. 

	^ noteCollection	
]

{ #category : 'accessing - notes' }
NTContainer >> notesCount [
	"Answer an <Integer> representing how many notes the receiver includes"
	
	^ self notes size
]

{ #category : 'accessing - notes' }
NTContainer >> notesTitleMatching: aString [
	"Answer a <Collection> with <NoteObject> objects whose title matched named aString"

	| pattern |
	pattern := '*' , aString , '*'.
	^ self notes select: [ :n | pattern match: n title ]
]

{ #category : 'removing - notes' }
NTContainer >> removeNote: aNTNoteObject [
	"Remove the note aNTNoteObject from the receiver's notes. Answer the receiver"
	
	self notes remove: aNTNoteObject
]

{ #category : 'removing - notes' }
NTContainer >> removeNoteNamed: aString [
	"Remove the note with title aString in the receiver's notes. Answer the receiver"
	
	self removeNote: (self noteNamed: aString)
]

{ #category : 'removing - notes' }
NTContainer >> removeNotes: aCollectionOfNTNoteObject [
	"Remove the note aNTNoteObject from the receiver's notes. Answer the receiver"
	
	self notes removeAll: aCollectionOfNTNoteObject
]

{ #category : 'removing - notes' }
NTContainer >> removeNotesSuchThat: aBlock [

	self notes copy do: [:each | 
		(aBlock value: each) 
			ifTrue: [ self removeNoteNamed: each title ] ]
]

{ #category : 'removing - tags' }
NTContainer >> removeTag: aNTTag [
	"Remove the note aNTNoteObject from the receiver's notes. Answer the receiver"

	self tags remove: aNTTag
]

{ #category : 'removing - tags' }
NTContainer >> removeTagNamed: aString [

	self removeTag: (self tagNamed: aString)
]

{ #category : 'accessing - tags' }
NTContainer >> tagNamed: aString [
	"Answer the first <NTNoteObject> matching aString in its name"

	^ self tags detect: [ :n | n tagName = aString ] ifNone: [ self addTagNamed: aString ]
]

{ #category : 'accessing - tags' }
NTContainer >> tags [
	"Answer the receiver's <Collection> of <NTNoteObject>"

	^ tags
]

{ #category : 'accessing - tags' }
NTContainer >> tags: aCollection [

	tags := aCollection
]

{ #category : 'accessing - tags' }
NTContainer >> tagsNameMatching: aString [
	"Answer a <Collection> with <NoteObject> objects whose title matched named aString"

	| pattern |
	pattern := '*' , aString , '*'.
	^ self tags select: [ :n | pattern match: n tagName ]
]
