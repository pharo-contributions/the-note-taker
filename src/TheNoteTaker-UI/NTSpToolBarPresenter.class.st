"
A toolbar with a text entry which has two roles when text is typed 

- A search for notes begins always, if any match then matching notes are returned.
- If none matches, then a new note is created after hitting **enter**

"
Class {
	#name : 'NTSpToolBarPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'noteSettingsButtonPresenter',
		'logButtonPresenter',
		'cloneGitButtonPresenter',
		'gitSaveButtonPresenter',
		'importFolderButtonPresenter'
	],
	#classVars : [
		'GitEnable'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'settings' }
NTSpToolBarPresenter class >> GitEnable [

	^ GitEnable
]

{ #category : 'settings' }
NTSpToolBarPresenter class >> GitEnable: aBoolean [

	GitEnable := aBoolean 
]

{ #category : 'settings' }
NTSpToolBarPresenter class >> settingsOn: aBuilder [

	<systemsettings>
	<pharoLauncherSettings>
	(aBuilder setting: #GitEnable)
		parent: #tnt;
		target: self;
		default: false;
		order: 60;
		label: 'enable git command';
		description:
			'When enabled, show git command button.
When disabled, hide git command button. '
]

{ #category : 'accessing' }
NTSpToolBarPresenter >> cloneGitButtonPresenter [

	^ cloneGitButtonPresenter
]

{ #category : 'layout' }
NTSpToolBarPresenter >> defaultLayout [

	GitEnable ifTrue: [ ^ self layoutWithGitButton ] ifFalse: [ ^ self layoutWithoutGitButton ]
]

{ #category : 'accessing' }
NTSpToolBarPresenter >> gitSaveButtonPresenter [

	^ gitSaveButtonPresenter
]

{ #category : 'accessing' }
NTSpToolBarPresenter >> importFolderButtonPresenter [

	^ importFolderButtonPresenter
]

{ #category : 'initialization' }
NTSpToolBarPresenter >> initializeCloneGitFolder [

	cloneGitButtonPresenter := self newButton
		                           icon: (self iconNamed: #into);
		                           addStyle: 'small';
		                           action: [
				                           NTSpGitCommand new
					                           context: self owner;
					                           clone ];
		                           help: 'Import a new git repository';
		                           yourself
]

{ #category : 'initialization' }
NTSpToolBarPresenter >> initializeGitSave [

	gitSaveButtonPresenter := self newButton
		                          icon: (self iconNamed: #delete);
		                          addStyle: 'small';
		                          action: [ NTSpGitCommand new context: self owner; execute ];
		                          help: 'Push current note folder to github';
		                          yourself
]

{ #category : 'initialization' }
NTSpToolBarPresenter >> initializeImportFolder [

	importFolderButtonPresenter := self newButton
		                               icon: (self iconNamed: #into);
		                               addStyle: 'small';
		                               action: [
				                               NTSpImportFolderCommand new
					                               context: self owner notesIndexPresenter ;
					                               execute ];
		                               help: 'Import a new folder';
		                               yourself
]

{ #category : 'initialization' }
NTSpToolBarPresenter >> initializeNoteSettingsButton [

	noteSettingsButtonPresenter := self newButton
		                               icon:
			                               (self iconNamed: #smallConfiguration);
		                               addStyle: 'small';
		                               action: [ self openTNTSettings ];
		                               help: 'Settings';
		                               yourself.
]

{ #category : 'initialization' }
NTSpToolBarPresenter >> initializePresenters [

	self initializeImportFolder.
	"self initializeCloneGitFolder."
	self initializeGitSave.
	self initializeNoteSettingsButton.
	self initializeLogButton.
]

{ #category : 'layout' }
NTSpToolBarPresenter >> layoutWithGitButton [

	^ SpBoxLayout newLeftToRight
		  add: gitSaveButtonPresenter expand: false;
		  "add: cloneGitButtonPresenter expand: false;"add:
			  importFolderButtonPresenter
		  expand: false;
		  add: noteSettingsButtonPresenter expand: false;
		  add: logButtonPresenter expand: false;
		  yourself
]

{ #category : 'layout' }
NTSpToolBarPresenter >> layoutWithoutGitButton [

	^ SpBoxLayout newLeftToRight
		  add: importFolderButtonPresenter expand: false;
		  add: noteSettingsButtonPresenter expand: false;
		  add: logButtonPresenter expand: false;
		  yourself
]

{ #category : 'accessing' }
NTSpToolBarPresenter >> noteSettingsButtonPresenter [

	^ noteSettingsButtonPresenter
]

{ #category : 'opening' }
NTSpToolBarPresenter >> openTNTSettings [

	self application registerWindow: (SettingBrowser new
	rootNodes: (SettingBrowser currentTree nodeNamed: #tnt) allChildren;
	open)
]
