"
I am a container who hold notes and tags. Usually the list of tags does not have duplicates names.

I can load a folder of notes and generates all the notes and their tags.

I have methods to create notes and tags, and for searching by their contents/names.
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
	"Add a new note with title aString to the receiver's notes"

	| newNote |
	self notes 
		detect: [ :note | note fileReference = aFileReference ] 
		ifFound: [ :note | ^ note]. 
	newNote := NTNote newFromFileReference: aFileReference.
	self loadFileContents: aFileReference contents for: newNote.
	self addNote: newNote.
	^ newNote
]

{ #category : 'adding - notes' }
NTContainer >> addNoteNamed: aString [
	"Add a new empty note with title aString to the receiver's notes."

	| note |
	note := NTNote content: aString.
	self addNote: note.
	^ note
]

{ #category : 'adding - tags' }
NTContainer >> addTagNamed: aString [

	| tag |
	tag := NTTag newNamed: aString.
	self tags add: tag.
	^ tag 
]

{ #category : 'loading - note' }
NTContainer >> dateAt: aKey in: aMetaData ifAbsent: aBlock [
	"Answer the <DateAndTime> stored under aKey in aMetaData, or the value of aBlock when missing"

	| value |
	self flag: #SD.
	"why can we have both a string or a date and time and all this logic 
	looks suspicious"
	value := aMetaData at: aKey ifAbsent: [ ^ aBlock value asDateAndTime ].
	^ value isString
		  ifTrue: [ DateAndTime fromString: value ]
		  ifFalse: [ value asDateAndTime ]
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

	aFolder ensureCreateDirectory.
	aFolder allFiles
		select: [ :fileRef |
				({ 'txt'. 'md'. 'text' } includes: fileRef extension asLowercase) and: [
					(fileRef path segments includes: self trashFolderName) not ] ]
		thenDo: [ :fileRef | self addNoteFromFileReference: fileRef ]
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
	aNTNote creationDate: (self dateAt: 'creationDate' in: metaData ifAbsent: [ aNTNote fileReference creationTime ]).
	aNTNote modificationDate: (self dateAt: 'lastModificationDate' in: metaData ifAbsent: [ aNTNote fileReference modificationTime ]).
	tagsString := metaData at: 'tags' ifAbsent: [ ^ self ].

	tagsString ifNotNil: [ (tagsString substrings: ',') do: [ :each | (self ensureTagNamed: each) addNote: aNTNote ] ]
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
		noteCollection := noteCollection select: [ :n | n tags includes: tag ]].

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
	"Remove the notes from the receiver's notes. Answer the receiver"

	self notes removeAll: aCollectionOfNTNoteObject
]

{ #category : 'accessing - tags' }
NTContainer >> removeTag: aNTTag fromNote: aNTNote [
	"Remove aNTTag from aNTNote, and from the receiver when no note uses it anymore"

	aNTNote removeTag: aNTTag.
	aNTTag notes ifEmpty: [ self tags remove: aNTTag ifAbsent: [ ] ]
]

{ #category : 'loading - note' }
NTContainer >> replaceFolder: aFolder [

	self notes: OrderedCollection new.
	self rawTags: OrderedCollection new.
	self importFolder: aFolder
]

{ #category : 'accessing - tags' }
NTContainer >> tags [
	"Answer the receiver's <Collection> of <NTNoteObject>"

	^ tags
]

{ #category : 'accessing - tags' }
NTContainer >> tagsNameMatching: aString [
	"Answer a <Collection> with <NoteObject> objects whose title matched named aString"

	| pattern |
	pattern := '*' , aString , '*'.
	^ self tags select: [ :n | pattern match: n tagName ]
]

{ #category : 'removing - notes' }
NTContainer >> trashFolderName [
	"Answer the name of the folder, next to a note, in which the note is moved when trashed"

	^ '.trash'
]

{ #category : 'removing - notes' }
NTContainer >> trashNote: aNTNote [
	"Move the file of aNTNote in the trash folder next to it and remove the note from the receiver"

	| trashFolder |
	aNTNote exists ifTrue: [
			trashFolder := aNTNote folderReference / self trashFolderName.
			trashFolder ensureCreateDirectory.
			aNTNote fileReference moveTo: trashFolder / (NTISOFileNamer new uniqueName: aNTNote fileName in: trashFolder) ].
	aNTNote tags copy do: [ :tag | self removeTag: tag fromNote: aNTNote ].
	self removeNotes: { aNTNote }
]
