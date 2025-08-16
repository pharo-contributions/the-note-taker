"
I hold notes and a list of all possible tags.
Usually the list of tags does not have duplicates.
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

	self notes add: aNTNoteObject
]

{ #category : 'adding - notes' }
NTContainer >> addNoteFromFileReference: aFileReference [
	"Add a new note with title aString to the receiver's notes. Answer the receiver"

	| newNote |
	newNote := NTNote newFromFileReference: aFileReference.
	self loadFileContents: aFileReference contents for: newNote.
	self notes add: newNote.
	^ newNote
]

{ #category : 'adding - notes' }
NTContainer >> addNoteNamed: aString [
	"Add a new empty note with title aString to the receiver's notes."

	| note |
	note := NTNote content: aString.
	self notes add: note.
	^ note
]

{ #category : 'adding - tags' }
NTContainer >> addTagNamed: aString [

	| tag |
	tag := NTTag newNamed: aString.
	self tags add: tag.
	^ tag 
]

{ #category : 'accessing - tags' }
NTContainer >> ensureTagNamed: aString [
	"Add a tag if it not already present"
	
	^ self tags
		  detect: [ :n | n tagName = aString ]
		  ifNone: [ self addTagNamed: aString ]
]

{ #category : 'loading - note' }
NTContainer >> importFolder: aFolder [

	aFolder allFiles
		select: [ :fileRef |
			{ 'txt'. 'md' .'text' } includes: fileRef extension asLowercase ]
		thenDo: [ :fileRef | "this test should be grouped somewhere else!"
			self addNoteFromFileReference: fileRef ].
]

{ #category : 'initialization' }
NTContainer >> initialize [

	super initialize.
	self notes: OrderedCollection new.
	self rawTags: OrderedCollection new
]

{ #category : 'loading - note' }
NTContainer >> loadFileContents: aString for: aNTNote [

	| fileContentsPart |
	(aString beginsWith: '{') ifFalse: [ ^ self ].
	fileContentsPart := aString substrings: '}'.
	aNTNote contents:
		(fileContentsPart second withoutPrefix: String crlf , String crlf).
	self loadMetaData: fileContentsPart first for: aNTNote
]

{ #category : 'loading - note' }
NTContainer >> loadMetaData: aString for: aNTNote [

	| metaData tagsString |
	metaData := (MicrodownParser parse: aString) metaDataElement.
	aNTNote creationDate: (metaData
			 at: 'creationDate'
			 ifAbsent: aNTNote fileReference creationTime) asDateAndTime.
	aNTNote modificationDate: (metaData
			 at: 'lastModificationDate'
			 ifAbsent: aNTNote fileReference modificationTime) asDateAndTime.
	tagsString := metaData at: 'tags' ifAbsent: [ ^ self ].

	tagsString ifNotNil: [
			(tagsString substrings: ',') do: [ :each |
				(self ensureTagNamed: each) addNote: aNTNote ] ]
]

{ #category : 'accessing - notes' }
NTContainer >> notes [

	^ notes
]

{ #category : 'accessing - notes' }
NTContainer >> notes: aCollection [

	notes := aCollection
]

{ #category : 'accessing - tags' }
NTContainer >> notes: aNotesCollection withTags: aTagsCollection [
	"Select the notes which defines a given list of tags"
	
	| noteCollection |
	noteCollection := aNotesCollection.
	aTagsCollection do: [ :tag |
		noteCollection := aNotesCollection select: [ :n | n tags includes: tag ]].

	^ noteCollection
]

{ #category : 'accessing - notes' }
NTContainer >> notesContentsMatching: aString [
	"Answer a <Collection> with <Note> objects whose contents matched named aString"
	
	| pattern |
	pattern := '*' , aString , '*'.
	^ self notes select: [ :n | pattern match: n contents ]
]

{ #category : 'accessing - notes' }
NTContainer >> notesCount [
	"Answer an <Integer> representing how many notes the receiver includes"
	
	^ self notes size
]

{ #category : 'private' }
NTContainer >> rawTags: aCollection [
	"Private use ensureTagNamed: to add tags."
	
	tags := aCollection
]

{ #category : 'removing - notes' }
NTContainer >> removeNotes: aCollectionOfNTNoteObject [
	"Remove the note aNTNoteObject from the receiver's notes. Answer the receiver"
	
	self notes removeAll: aCollectionOfNTNoteObject
]

{ #category : 'accessing - tags' }
NTContainer >> tags [
	"Answer the receiver's <Collection> of <NTNoteObject>"

	^ tags
]

{ #category : 'private' }
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
