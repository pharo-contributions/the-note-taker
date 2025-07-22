Class {
	#name : 'NTSpLogPresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'memoryFS'
	],
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'running' }
NTSpLogPresenterTest >> setUp [
	super setUp.

	memoryFS := FileSystem memory.
]

{ #category : 'tests' }
NTSpLogPresenterTest >> testCreateFileLogWhenDontExist [

	| logWindow logReference | self skip.
	logReference := memoryFS workingDirectory / 'TheNoteTaker.log'.

	logWindow := ('NTSpLogPresenter' openLogOfFolder: memoryFS) open.

	self assert: logReference exists.

	logWindow close
]

{ #category : 'tests' }
NTSpLogPresenterTest >> testOpenFileLog [

	| logWindow logReference |self skip.
	logReference := memoryFS workingDirectory / 'TheNoteTaker.log'.
	logReference writeStreamDo: [ :stream |
		stream nextPutAll: 'Log Test' ].

	logWindow := ('NTSpLogPresenter' openLogOfFolder: memoryFS) open.

	self
		assert: logWindow presenter contents
		equals: logReference contents.

	logWindow close
]
