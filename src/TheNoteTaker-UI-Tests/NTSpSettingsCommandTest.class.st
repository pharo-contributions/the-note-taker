"
I test `NTSpSettingsCommand`: it opens an `NTSettingsPresenter` on the settings of the application, and saving the editor writes the preferences file of the application.

## Responsibility:

- I check which settings the opened editor edits.
- I check that accepting the editor exports the settings to the application preferences file.

## Collaborators:

- `SpWindowSimulateOpenModal`: answers the opened dialog without showing it.
- `NTApplication`: its preferences file is in a memory file system (see `NTSpTestCase>>setUp`).
"
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
NTSpSettingsCommandTest >> testAcceptingTheEditorSavesThePreferencesFile [

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter gitCheckBox state: true.
				aDialogPresenter presenter accept ]
		during: [ command execute ].
	self assert: ((STON fromString: app preferencesFile contents) at: 'gitEnable')
]

{ #category : 'tests' }
NTSpSettingsCommandTest >> testExecuteOpensAnEditorOnTheApplicationSettings [

	| editor |
	editor := nil.
	SpWindowSimulateOpenModal value: [ :aDialogPresenter | editor := aDialogPresenter presenter ] during: [ command execute ].
	self assert: editor class equals: NTSettingsPresenter.
	self assert: editor model identicalTo: app settings
]
