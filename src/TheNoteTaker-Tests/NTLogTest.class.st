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
	note := NTNote content: 'noteTest'.
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

	self assert: (log add: note tag: tag) equals: 'tag ', tag tagName, ' has been add to the note ', note fileName.
	self assert: ((memory / 'TheNoteTaker.log') contents endsWith:
			 'tag ' , tag tagName , ' has been add to the note '
			 , note fileName , String cr)
]

{ #category : 'running' }
NTLogTest >> testWriteCreate [

	self assert: (log create: note) equals: 'file ' , note fileName , ' has been created'.
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

	self assert: (log remove: note) equals: 'file ' , note fileName , ' has been deleted'.
	self assert: ((memory / 'TheNoteTaker.log') contents endsWith:
			 'file ' , note fileName , ' has been deleted' , String cr)
]

{ #category : 'running' }
NTLogTest >> testWriteRemoveTag [

	self
		assert: (log remove: note tag: tag)
		equals: 'tag ' , tag tagName , ' has been removed to the note ' , note fileName.
	self assert: ((memory / 'TheNoteTaker.log') contents endsWith:
			 'tag ' , tag tagName , ' has been removed to the note '
			 , note fileName , String cr)
]

{ #category : 'running' }
NTLogTest >> testWriteSave [

	self assert: (log save: note) equals: 'file ', note fileName, ' has been saved'.
	self assert: ((memory / 'TheNoteTaker.log') contents endsWith:
			 'file ' , note fileName , ' has been saved' , String cr)
]
