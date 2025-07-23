Class {
	#name : 'NTSpSettingsCommandTest',
	#superclass : 'NTSpCommandTest',
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'running' }
NTSpSettingsCommandTest >> setUp [

	super setUp.

	command := NTSpSettingsCommand new context: mainPresenter
]

{ #category : 'tests' }
NTSpSettingsCommandTest >> testOpenTNTSettings [

	self skip.
	SpWindowForceOpenNonModal during: [
		command execute ].

	self assert: app windows size equals: 1
]
