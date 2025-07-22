Class {
	#name : 'NTSpToolbarPresenterTest',
	#superclass : 'TestCase',
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testImportFolderButtonOpenModalWindow [

	self skip.
	"SpWindowForceOpenNonModal during: [
		notesToolbarPresenter importFolderButtonPresenter click ].

	self assert: notesToolbarPresenter application windows size equals: 2"
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testOpenLogButtonOpenModalWindow [
self skip.
	SpWindowForceOpenNonModal during: [
		toolbarPresenter logButtonPresenter click ].
	self currentWorld doOneCycle.

	self assert: toolbarPresenter application windows size equals: 2
]

{ #category : 'tests' }
NTSpToolbarPresenterTest >> testOpenTNTSettingsButtonOpenModalWindow [

	self skip.
	SpWindowForceOpenNonModal during: [
		toolbarPresenter noteSettingsButtonPresenter click ].

	self assert: toolbarPresenter application windows size equals: 2
]
