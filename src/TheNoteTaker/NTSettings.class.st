Class {
	#name : 'NTSettings',
	#superclass : 'Object',
	#traits : 'TObservable',
	#classTraits : 'TObservable classTrait',
	#instVars : [
		'#currentFolder => ObservableSlot',
		'#gitEnable => ObservableSlot'
	],
	#classVars : [
		'#Default'
	],
	#category : 'TheNoteTaker-Core',
	#package : 'TheNoteTaker',
	#tag : 'Core'
}

{ #category : 'private' }
NTSettings class >> CurrentFolder [

	^ self Default currentFolder
]

{ #category : 'private' }
NTSettings class >> CurrentFolder: aFileReference [

	self Default currentFolder: aFileReference
]

{ #category : 'private' }
NTSettings class >> Default [

	^ Default ifNil: [ Default := self new ]
]

{ #category : 'private' }
NTSettings class >> Default: aNTSettings [

	Default := aNTSettings
]

{ #category : 'commands' }
NTSettings class >> GitEnable [

	^ self Default gitEnable
]

{ #category : 'commands' }
NTSettings class >> GitEnable: aBoolean [

	self Default gitEnable: aBoolean
]

{ #category : 'commands' }
NTSettings class >> new [

	| instance |
	instance := super new.
	Default := instance.
	^ instance
]

{ #category : 'settings' }
NTSettings class >> reset [

	<script>
	Default := nil
]

{ #category : 'settings' }
NTSettings class >> settingsOn: aBuilder [

	<systemsettings>
	(aBuilder group: #tnt)
		label: 'The Note Taker';
		description: 'All TNT related settings';
		noOrdering;
		with: [
				(aBuilder setting: #CurrentFolder)
					label: 'Project Path';
					type: #Directory;
					ghostHelp:
						'/Users/ducasse/Workspace/FirstCircle/Writing/Working/researchnotes';
					description:
						'Enter your local or remote path where notes will be committed. It can be empty'.
				(aBuilder setting: #GitEnable)
					parent: #tnt;
					target: self;
					order: 60;
					label: 'enable git command';
					description: 'When enabled, show git command button.
When disabled, hide git command button. ' ]
]

{ #category : 'enumerating' }
NTSettings >> currentFolder [

	^ currentFolder ifNil: [
			  currentFolder := (FileLocator documents / 'noteTaker')
				                   asFileReference ensureCreateDirectory ]
]

{ #category : 'enumerating' }
NTSettings >> currentFolder: aFileReference [
	
	currentFolder := aFileReference
]

{ #category : 'enumerating' }
NTSettings >> gitEnable [

	^ gitEnable ifNil: [ gitEnable := false ]
]

{ #category : 'enumerating' }
NTSettings >> gitEnable: aBoolean [

	gitEnable := aBoolean
]

{ #category : 'initialization' }
NTSettings >> initialize [

	self class initializeSlots: self.
	super initialize.
]

{ #category : 'enumerating' }
NTSettings >> whenCurrentFolderChangeDo: aBlock [

	self property: #currentFolder whenChangedDo: aBlock
]

{ #category : 'enumerating' }
NTSettings >> whenGitEnableChangeDo: aBlock [

	self property: #gitEnable whenChangedDo: aBlock
]
