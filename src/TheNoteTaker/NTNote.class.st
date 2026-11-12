"
It represents a single note. A note is composed of :

- A contents
- A fileReference
- A creationDate
- A modificationDate
- A tags list

The note has a title representing the first contents line.
When we saved a note, we create metadata by Microdown with the modificationDate, creationDate and the tags list, and we put it in the start of the note file. Then we complete with the contents



"
Class {
	#name : 'NTNote',
	#superclass : 'Object',
	#instVars : [
		'title',
		'creationDate',
		'modificationDate',
		'tags',
		'contents',
		'folderReference',
		'fileName'
	],
	#category : 'TheNoteTaker-Core',
	#package : 'TheNoteTaker',
	#tag : 'Core'
}

{ #category : 'instance creation' }
NTNote class >> content: aString [
	"Answer a new instance of the receiver with title aString"

	| note |
	note := self new.

	^ note
		  contents: aString;
		  modificationDate: note creationDate;
		  yourself
]

{ #category : 'instance creation' }
NTNote class >> newFromFileReference: aFileReference [

	^ self new
		  folderReference: aFileReference parent;
		  fileName: aFileReference basename;
		contents: aFileReference contents;
		  creationDate: aFileReference creationTime;
		  modificationDate: aFileReference modificationTime;
		  yourself
]

{ #category : 'file format' }
NTNote class >> splitFileContents: aString into: aBlock [
	"Separate the metadata block that starts a note file from the note contents.
	Evaluate aBlock with the metadata string (nil when there is none) and the contents.
	The metadata block ends at the first line ending with a closing brace, so braces in the contents are kept."

	(aString beginsWith: '{') ifFalse: [ ^ aBlock value: nil value: aString ].
	aString lineIndicesDo: [ :start :endWithoutDelimiters :end |
		((aString copyFrom: start to: endWithoutDelimiters) trimRight endsWith: '}') ifTrue: [
			^ aBlock
				  value: (aString copyFrom: 1 to: endWithoutDelimiters)
				  value: (self withoutLeadingLineBreak: (aString allButFirst: end)) ] ].
	^ aBlock value: nil value: aString
]

{ #category : 'private - file format' }
NTNote class >> withoutLeadingLineBreak: aString [
	"Remove the empty line written between the metadata block and the contents"

	(aString beginsWith: String crlf) ifTrue: [ ^ aString allButFirst: 2 ].
	((aString beginsWith: String cr) or: [ aString beginsWith: String lf ]) ifTrue: [ ^ aString allButFirst ].
	^ aString
]

{ #category : 'accessing - tags' }
NTNote >> addTag: aNTTag [

	self tags detect: [ :tag | tag tagName = aNTTag tagName ] ifNone: [
			self tags add: aNTTag.
			aNTTag addNote: self ]
]

{ #category : 'accessing' }
NTNote >> contents [

	^ contents
]

{ #category : 'accessing' }
NTNote >> contents: anObject [

	contents := anObject.
	self modificationDate: DateAndTime now.
	self generateTitle
]

{ #category : 'accessing' }
NTNote >> creationDate [

	^ creationDate
]

{ #category : 'accessing' }
NTNote >> creationDate: aDateAndTime [

	creationDate := aDateAndTime
]

{ #category : 'testing' }
NTNote >> exists [

	^ self fileReference exists
]

{ #category : 'accessing' }
NTNote >> fileName [

	fileName ifNil: [
			| namer |
			namer := NTISOFileNamer new date: creationDate asDate.
			self fileName: (namer uniqueName: (namer newNameBasedOn: self title) in: self folderReference) ].
	^ fileName
]

{ #category : 'accessing' }
NTNote >> fileName: aString [

	fileName := aString
]

{ #category : 'accessing' }
NTNote >> fileReference [

	^ self folderReference / self fileName
]

{ #category : 'accessing' }
NTNote >> fileReferenceContents [
	"Answer the contents of the note as saved in its file, without the metadata"

	^ self class
		  splitFileContents: self fileReference contents
		  into: [ :metaData :fileContents | fileContents ]
]

{ #category : 'accessing' }
NTNote >> folderReference [

	^ folderReference ifNil: [
		folderReference := FileSystem workingDirectory ].
]

{ #category : 'accessing' }
NTNote >> folderReference: aFileReference [

	folderReference := aFileReference.
]

{ #category : 'generate' }
NTNote >> generateMetaDataElements [

	| meta |
	meta := MicMetaDataBlock new.
	meta body: Dictionary new.
	meta
		atKey: 'creationDate' put: self creationDate asString;
		atKey: 'lastModificationDate' put: self modificationDate asString.
	self tags ifNotEmpty: [ meta atKey: 'tags' put: self tagsNameString ].

	^ (MicTextualMicrodownExporter new visit: meta) contents
]

{ #category : 'generate' }
NTNote >> generateTitle [
	"create a new title which corresponds to the first line of the contents"

	| collection |
	collection := (contents substrings: String crlf).
	collection isNotEmpty
		ifTrue: [ self title: collection first ]
		ifFalse: [ self title: 'unnamed' ]
]

{ #category : 'initialization' }
NTNote >> initialize [

	super initialize.
	contents := String empty.
	creationDate := DateAndTime now.
	modificationDate := creationDate.
	tags := Set new
]

{ #category : 'testing' }
NTNote >> isDirty [

	self exists ifFalse: [ ^ true ].
	^ contents ~= self fileReferenceContents
]

{ #category : 'testing' }
NTNote >> isNote [

	^ true
]

{ #category : 'accessing' }
NTNote >> modificationDate [

	^ modificationDate
]

{ #category : 'accessing' }
NTNote >> modificationDate: aDateAndTime [

	modificationDate := aDateAndTime
]

{ #category : 'printing' }
NTNote >> printOn: aStream [

	super printOn: aStream.
	aStream
		<< '[';
		<<  self title asString;
		<< ']'
]

{ #category : 'accessing - tags' }
NTNote >> removeTag: aNTTag [

	self tags remove: aNTTag ifAbsent: [ ^ self ].
	aNTTag removeNote: self
]

{ #category : 'saving' }
NTNote >> save [

	self fileReference ensureDelete.
	self fileReference writeStreamDo: [ :str |
			str << self generateMetaDataElements.
			str << String crlf.
			str << String crlf.
			str << contents ]
]

{ #category : 'accessing - tags' }
NTNote >> tags [

	^ tags
]

{ #category : 'accessing - tags' }
NTNote >> tags: anObject [

	tags := anObject
]

{ #category : 'accessing - tags' }
NTNote >> tagsNameString [
	"Answer a <String> to be displayed"

	| tagsNameList |
	tagsNameList := self tags collect: [ :each | each tagName ].
	^ (tagsNameList asOrderedCollection sorted: [ :a :b | a < b ])
		  joinUsing: ','
]

{ #category : 'accessing' }
NTNote >> title [

	title ifNil: [ self generateTitle].
	^ title
]

{ #category : 'accessing' }
NTNote >> title: aString [

	title := aString
]
