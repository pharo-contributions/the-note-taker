Extension { #name : 'MDFile' }

{ #category : '*TheNoteTaker' }
MDFile class >> newFromNote: aNTNoteObject [
	"Answer a new <MDFile> using aNTNoteObject contents and title"

	| fileReference |
	fileReference := (aNTNoteObject title , self fileExtension) asFileReference.
	fileReference writeStreamDo: [ : writeStream | writeStream << aNTNoteObject contents ].
	^ self new
		file: 	fileReference;
		yourself
]
