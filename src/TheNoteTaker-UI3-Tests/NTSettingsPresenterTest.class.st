"
I test `NTSettingsPresenter`, the editor of `NTSettings`: its fields show the settings and are written into them only when the editor is accepted.

## Responsibility:

- I check that each field shows the value of its setting.
- I check that `accept` writes the edited values, and only valid ones, and runs the blocks given to `whenAcceptedDo:`.
- I never open a window: the presenter is tested through its fields.

## Collaborators:

- `NTSettings`: the edited settings, created with `new` so that the user's settings file is not touched.
- `SpApplication`: the application of the presenter.
"
Class {
	#name : 'NTSettingsPresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'settings',
		'presenter'
	],
	#category : 'TheNoteTaker-UI3-Tests-Settings',
	#package : 'TheNoteTaker-UI3-Tests',
	#tag : 'Settings'
}

{ #category : 'running' }
NTSettingsPresenterTest >> setUp [

	super setUp.
	settings := NTSettings new
		            currentFolder: '/Users/me/Notes' asFileReference;
		            gitEnable: true;
		            listMode: #byTag;
		            showsTags: false;
		            autosaveSeconds: 30;
		            yourself.
	presenter := NTSettingsPresenter newApplication: SpApplication new model: settings
]

{ #category : 'tests' }
NTSettingsPresenterTest >> testAcceptKeepsAutosaveSecondsBelowOne [

	presenter autosaveInput number: 0.
	presenter accept.
	self assert: settings autosaveSeconds equals: 30
]

{ #category : 'tests' }
NTSettingsPresenterTest >> testAcceptKeepsTheFolderWhenItsPathIsUnchanged [

	| folder |
	folder := FileSystem memory root / 'notes'.
	settings currentFolder: folder.
	presenter := NTSettingsPresenter newApplication: SpApplication new model: settings.
	presenter accept.
	self assert: settings currentFolder identicalTo: folder
]

{ #category : 'tests' }
NTSettingsPresenterTest >> testAcceptRunsTheAcceptedBlocks [

	| accepted |
	accepted := false.
	presenter whenAcceptedDo: [ accepted := true ].
	presenter accept.
	self assert: accepted
]

{ #category : 'tests' }
NTSettingsPresenterTest >> testAcceptWithEmptyFolderKeepsTheFolder [

	presenter folderInput text: '  '.
	presenter accept.
	self assert: settings currentFolder fullName equals: '/Users/me/Notes'
]

{ #category : 'tests' }
NTSettingsPresenterTest >> testAcceptWritesTheEditedValues [

	presenter folderInput text: '/Users/me/Other'.
	presenter gitCheckBox state: false.
	presenter listModeDropDown selectItem: #compact.
	presenter showsTagsCheckBox state: true.
	presenter autosaveInput number: 5.
	presenter accept.
	self assert: settings currentFolder fullName equals: '/Users/me/Other'.
	self deny: settings gitEnable.
	self assert: settings listMode equals: #compact.
	self assert: settings showsTags.
	self assert: settings autosaveSeconds equals: 5
]

{ #category : 'tests' }
NTSettingsPresenterTest >> testAutosaveInputShowsTheAutosaveSeconds [

	self assert: presenter autosaveInput number equals: 30
]

{ #category : 'tests' }
NTSettingsPresenterTest >> testChoosingAFolderShowsItsPath [

	presenter folderChosen: '/Users/me/Chosen' asFileReference.
	self assert: presenter folderInput text equals: '/Users/me/Chosen'
]

{ #category : 'tests' }
NTSettingsPresenterTest >> testEditingDoesNotChangeTheSettingsBeforeAccept [

	presenter gitCheckBox state: false.
	presenter autosaveInput number: 5.
	self assert: settings gitEnable.
	self assert: settings autosaveSeconds equals: 30
]

{ #category : 'tests' }
NTSettingsPresenterTest >> testFolderFieldShowsTheFolder [

	self assert: presenter folderInput text equals: '/Users/me/Notes'
]

{ #category : 'tests' }
NTSettingsPresenterTest >> testGitCheckBoxShowsGitEnable [

	self assert: presenter gitCheckBox state
]

{ #category : 'tests' }
NTSettingsPresenterTest >> testListModeDropDownOffersEveryListMode [

	self assert: presenter listModeDropDown items asArray equals: NTSettings listModes
]

{ #category : 'tests' }
NTSettingsPresenterTest >> testListModeDropDownShowsTheListMode [

	self assert: presenter listModeDropDown selectedItem equals: #byTag
]

{ #category : 'tests' }
NTSettingsPresenterTest >> testListModeLabels [

	self
		assert: (NTSettings listModes collect: [ :each | presenter labelOfListMode: each ])
		equals: #( 'By date' 'By tag' 'Titles only' )
]

{ #category : 'tests' }
NTSettingsPresenterTest >> testShowsTagsCheckBoxShowsShowsTags [

	self deny: presenter showsTagsCheckBox state
]
