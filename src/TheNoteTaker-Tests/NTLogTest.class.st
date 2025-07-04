Class {
	#name : 'NTLogTest',
	#superclass : 'TestCase',
	#instVars : [
		'log',
		'memory',
		'note',
		'tag'
	],
	#category : 'TheNoteTaker-Tests-Core',
	#package : 'TheNoteTaker-Tests',
	#tag : 'Core'
}

{ #category : 'running' }
NTLogTest >> setUp [

	super setUp.
	memory := FileSystem memory workingDirectory.
	log := NTLog newWithFolder: memory.
	log noteTakerMain:
		(NTSpNoteTakerMainUI newApplication: NTSpApplication new).
	note := NTNoteObject named: 'noteTest'.
	tag := NTTag newNamed: 'tagTest'
]

{ #category : 'running' }
NTLogTest >> testCreateLogFile [

	log write: 'Test'.
	self assert: (memory / 'TheNoteTaker.log') exists 
]

{ #category : 'running' }
NTLogTest >> testWrite [

	log write: 'Test'.
	self assert: ((memory / 'TheNoteTaker.log') contents endsWith: 'Test', String cr)
]

{ #category : 'running' }
NTLogTest >> testWriteAddTag [

	log add: note tag: tag.
	self assert:
		((memory / 'TheNoteTaker.log') contents endsWith: 'tag ' , tag tagName , ' has been add to the note '
		, note fileName , String cr)
]

{ #category : 'running' }
NTLogTest >> testWriteCreate [

	log create: note.
	self assert: ((memory / 'TheNoteTaker.log') contents endsWith:
			 'file ' , note fileName , ' has been created' , String cr)
]

{ #category : 'running' }
NTLogTest >> testWriteMultipleLine [

	log write: 'Test'.
	log write: 'Test 2'.
	self
		assert:
		((memory / 'TheNoteTaker.log') contents substrings: String cr) size
		equals: 2.
	
	self assert:
		((memory / 'TheNoteTaker.log') contents endsWith: 'Test 2' , String cr)
]

{ #category : 'running' }
NTLogTest >> testWriteRemove [

	log remove: note.
	self assert: ((memory / 'TheNoteTaker.log') contents endsWith:
			 'file ' , note fileName , ' has been deleted' , String cr)
]

{ #category : 'running' }
NTLogTest >> testWriteRemoveTag [

	log remove: note tag: tag.
	self assert: ((memory / 'TheNoteTaker.log') contents endsWith:
			 'tag ' , tag tagName , ' has been removed to the note '
			 , note fileName , String cr)
]

{ #category : 'running' }
NTLogTest >> testWriteSave [

	log save: note.
	self assert:
		((memory / 'TheNoteTaker.log') contents endsWith: 'file ' , note fileName , ' has been saved' , String cr)
]
