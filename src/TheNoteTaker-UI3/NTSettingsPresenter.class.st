"
I am the editor of `NTSettings`: a small form with the notes folder, the mode of the note list, whether the list shows tags, the autosave delay and the git switch.
My fields are written into the settings only when I am accepted, so Cancel leaves them untouched.

## Life cycle: who creates me and who uses me

1. `NT3NoteListPresenter>>#openSettings` (the settings button of the note list) creates me on the settings of its `NT3Application` (`self application instantiate: NTSettingsPresenter on: settings`) and opens me in a modal dialog.
2. `modelChanged` fills my fields from the settings.
3. The Save button of my dialog sends me `accept`: I write my fields into the settings, then run the blocks given to `whenAcceptedDo:` (the note list then shows the new mode and tags). Cancel closes me without writing.

## Responsibility:

- I show each setting in a field: a text input with a Choose… button (a `StOpenDirectoryPresenter` folder dialog), a drop list, check boxes and an integer input.
- I write the edited values back on `accept`, keeping the folder when its path is empty or unchanged and the delay when it is under one second.
- I tell my listeners when the settings were accepted.

## Collaborators:

- `NTSettings`: my model.
- `StOpenDirectoryPresenter`: lets the user choose the notes folder.
- `NT3NoteListPresenter`: opens me from its settings button.

## Public API and Key Messages

- `NTSettingsPresenter newApplication: anApplication model: someSettings`, or `anApplication instantiate: NTSettingsPresenter on: someSettings`.
- `openDialog` or `openModal` shows me with Save and Cancel buttons.
- `accept` writes the fields into the settings; `whenAcceptedDo: aBlock`.

## Examples

```
NTSettingsPresenter example.
NTSettingsPresenter scriptEditSettingsSavedInAStonFile.
```

## Internal Representation

- `folderInput`, `chooseFolderButton`, `listModeDropDown` (a drop list of `NTSettings listModes`), `showsTagsCheckBox`, `autosaveInput`, `gitCheckBox`: my fields.
- `acceptedBlocks`: the blocks run after `accept`.

### Implementation Points

I use a `SpDropListPresenter`: `SpEasyDropDownPresenter` has no Morphic adapter.
"
Class {
	#name : 'NTSettingsPresenter',
	#superclass : 'SpPresenterWithModel',
	#instVars : [
		'folderInput',
		'chooseFolderButton',
		'gitCheckBox',
		'listModeDropDown',
		'showsTagsCheckBox',
		'autosaveInput',
		'acceptedBlocks'
	],
	#category : 'TheNoteTaker-UI3-Settings',
	#package : 'TheNoteTaker-UI3',
	#tag : 'Settings'
}

{ #category : 'examples' }
NTSettingsPresenter class >> example [
	"An editor on sample settings, not opened"

	<sampleInstance>
	^ self newApplication: SpApplication new model: NTSettings exampleWithGitEnabled
]

{ #category : 'script' }
NTSettingsPresenter class >> scriptEditSettingsSavedInAStonFile [
	"Edit settings persisted to a STON file in memory. Press Save: the editor writes the settings, which rewrite the file, and the file contents are shown"

	<example>
	| settings file editor |
	file := FileSystem memory root / 'TheNoteTaker' / 'settings.ston'.
	settings := NTSettings new.
	settings persistTo: file.
	editor := self newApplication: SpApplication new model: settings.
	editor whenAcceptedDo: [ editor inform: file contents ].
	^ editor openDialog
]

{ #category : 'actions' }
NTSettingsPresenter >> accept [
	"Write the edited values into the settings, then run the accepted blocks.
	The folder changes only when its path was edited and is not empty; the delay only when it is at least one second"

	| path |
	path := folderInput text trimBoth.
	(path isNotEmpty and: [ path ~= self model currentFolder asFileReference fullName ]) ifTrue: [
		self model currentFolder: path asFileReference ].
	self model
		gitEnable: gitCheckBox state;
		listMode: listModeDropDown selectedItem;
		showsTags: showsTagsCheckBox state.
	autosaveInput number >= 1 ifTrue: [ self model autosaveSeconds: autosaveInput number ].
	acceptedBlocks do: [ :each | each value ]
]

{ #category : 'accessing' }
NTSettingsPresenter >> autosaveInput [

	^ autosaveInput
]

{ #category : 'actions' }
NTSettingsPresenter >> chooseFolder [
	"Let the user choose the folder of the notes in a folder dialog"

	| start |
	start := folderInput text asFileReference.
	start exists ifFalse: [ start := FileLocator documents asFileReference ].
	StOpenDirectoryPresenter new
		application: self application;
		title: 'Choose the folder of the notes';
		openFolder: start;
		okAction: [ :directory | self folderChosen: directory ];
		openModal
]

{ #category : 'initialization' }
NTSettingsPresenter >> connectPresenters [

	chooseFolderButton action: [ self chooseFolder ]
]

{ #category : 'layout' }
NTSettingsPresenter >> defaultLayout [

	^ SpGridLayout build: [ :builder |
			  builder
				  beColumnNotHomogeneous;
				  column: 2 expand: true;
				  add: 'Notes folder';
				  add: (SpBoxLayout newLeftToRight
						   spacing: 5;
						   add: folderInput;
						   add: chooseFolderButton expand: false;
						   yourself);
				  nextRow;
				  add: 'Note list';
				  add: listModeDropDown;
				  nextRow;
				  add: '';
				  add: showsTagsCheckBox;
				  nextRow;
				  add: 'Autosave after (seconds)';
				  add: autosaveInput;
				  nextRow;
				  add: '';
				  add: gitCheckBox ]
]

{ #category : 'actions' }
NTSettingsPresenter >> folderChosen: aDirectory [

	folderInput text: aDirectory fullName
]

{ #category : 'accessing' }
NTSettingsPresenter >> folderInput [

	^ folderInput
]

{ #category : 'accessing' }
NTSettingsPresenter >> gitCheckBox [

	^ gitCheckBox
]

{ #category : 'initialization' }
NTSettingsPresenter >> initializeDialogWindow: aDialogWindowPresenter [

	aDialogWindowPresenter
		title: 'Note Taker settings';
		initialExtent: 520 @ 280;
		addButton: 'Cancel' do: [ :dialog | dialog close ];
		addDefaultButton: 'Save' do: [ :dialog |
				self accept.
				dialog close ]
]

{ #category : 'initialization' }
NTSettingsPresenter >> initializePresenters [

	acceptedBlocks := OrderedCollection new.
	folderInput := self newTextInput
		               placeholder: 'Folder of the notes';
		               yourself.
	chooseFolderButton := self newButton
		                      label: 'Choose…';
		                      help: 'Choose the folder of the notes';
		                      yourself.
	listModeDropDown := self newDropList
		                    items: NTSettings listModes;
		                    display: [ :each | self labelOfListMode: each ];
		                    yourself.
	showsTagsCheckBox := self newCheckBox
		                     label: 'Show the tags in the note list';
		                     yourself.
	autosaveInput := self newNumberInput
		                 beInteger;
		                 minimum: 1;
		                 yourself.
	gitCheckBox := self newCheckBox
		               label: 'Show the git commands';
		               yourself
]

{ #category : 'accessing' }
NTSettingsPresenter >> labelOfListMode: aSymbol [
	"Answer the label shown for the list mode named aSymbol"

	^ {
		  (#byDate -> 'By date').
		  (#byTag -> 'By tag').
		  (#compact -> 'Titles only') } asDictionary at: aSymbol
]

{ #category : 'accessing' }
NTSettingsPresenter >> listModeDropDown [

	^ listModeDropDown
]

{ #category : 'initialization' }
NTSettingsPresenter >> modelChanged [
	"Show the values of the edited settings in the fields"

	folderInput text: self model currentFolder asFileReference fullName.
	gitCheckBox state: self model gitEnable.
	listModeDropDown selectItem: self model listMode.
	showsTagsCheckBox state: self model showsTags.
	autosaveInput number: self model autosaveSeconds
]

{ #category : 'accessing' }
NTSettingsPresenter >> showsTagsCheckBox [

	^ showsTagsCheckBox
]

{ #category : 'events' }
NTSettingsPresenter >> whenAcceptedDo: aBlock [
	"Run aBlock each time the edited values are written into the settings"

	acceptedBlocks add: aBlock
]
