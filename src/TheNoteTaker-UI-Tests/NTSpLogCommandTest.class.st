Class {
	#name : 'NTSpLogCommandTest',
	#superclass : 'NTSpCommandTest',
	#instVars : [
		'logCommand'
	],
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'running' }
NTSpLogCommandTest >> setUp [

	super setUp.

	logCommand := NTSpLogCommand new context: indexPresenter
]

{ #category : 'tests' }
NTSpLogCommandTest >> testCreateFileLogWhenDontExist [

	| logReference |
	
	logReference := memoryFS workingDirectory / 'TheNoteTaker.log'.
	
	SpWindowForceOpenNonModal during: [
		logCommand execute].
	self currentWorld doOneCycle.

	self assert: app windows size equals: 1.

	self assert: logReference exists
]

{ #category : 'tests' }
NTSpLogCommandTest >> testOpenFileLog [

	| logReference contents |

	logReference := memoryFS workingDirectory / 'TheNoteTaker.log'.
	logReference writeStreamDo: [ :stream |
		stream nextPutAll: 'Log Test' ].


	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
		contents := aDialogPresenter presenter text ]
		during: [ logCommand execute ].

	self assert: contents equals: logReference contents
]
