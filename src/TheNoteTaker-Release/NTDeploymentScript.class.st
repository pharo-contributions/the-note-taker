"
I'm responsible for preparing the image to be a The Note Taker image. Namely, I make sure that

- one The Note Taker window is open and centered
- this window can't be closed easily
- the user-defined startup scripts are not executed
"
Class {
	#name : 'NTDeploymentScript',
	#superclass : 'Object',
	#classVars : [
		'DefaultDebuggerRank',
		'Save'
	],
	#category : 'TheNoteTaker-Release',
	#package : 'TheNoteTaker-Release'
}

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> activateDeprecationWarnings [
	Deprecation raiseWarning: true
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> activateErrorCatching [
	DefaultDebuggerRank := StDebugger rank.
	StDebugger rank: 9.
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> activateLostChangesDetector [
	EpLostChangesDetector initialize
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> activateStartupActions [
	StartupPreferencesLoader allowStartupScript: true.
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> askForConfirmationWhenQuitting [
	"self flag: 'TODO'."
	"Since UserManager is now over, there is no clean way to avoid warning when we juast ask to quit the image. More general, there should be a way to have an image in read/only mode"
	Save := true
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> closeAllWindows [
	"We make sure we always close without asking for confirmation. It looks like #closeAllWindowsDiscardingChanges doesn't work as a startup action."
	[ World closeAllWindowsDiscardingChanges ]
		on: ProvideAnswerNotification
		do: [ :err | err return: false ].
	World submorphs do: #delete.
	NTSpApplication default closeAllWindows.
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> closeWindowsAndOpenDevelopmentEnvironment [
self flag: 'LOOK'.
	PanelMorph allInstancesDo: [ :pm | pm delete ].
	self closeAllWindows.
	TaskbarMorph reset.
	MenubarMorph reset.
	Smalltalk tools openWorkspace presenter contents: 'NTSpApplication openIt'. 

	"PanelMorph comes from use of #openWorldWithSpec"
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> closeWindowsAndOpenLauncher [
	self 
		closeAllWindows;
		openLauncher
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> deactivateDeprecationWarnings [
	Deprecation raiseWarning: false
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> deactivateErrorCatching [
	StDebugger rank: DefaultDebuggerRank
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> deactivateLostChangesDetector [
	SessionManager default unregisterClassNamed: #EpLostChangesDetector
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> deactivateStartupActions [
	StartupPreferencesLoader allowStartupScript: false.
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> developmentEnvironmentEnabled [
	^ self isDeployed not
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> developmentEnvironmentEnabled: aBoolean [
	aBoolean 
		ifTrue: 
		[	self undoAll.  	
			self closeWindowsAndOpenDevelopmentEnvironment 
		]
		ifFalse: 
		[ 	self doAll. 
			self closeWindowsAndOpenLauncher.
			self isDeployed ifFalse: [ Smalltalk snapshot: true andQuit: false "save deployed mode" ]
		].
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> doAll [
	self
		closeAllWindows;
		removeAllMorphs;
		deactivateStartupActions;
		dontRaiseWarningForMissingChangesOrSourcesFiles;
		deactivateDeprecationWarnings;
		deactivateLostChangesDetector;
		activateErrorCatching;
		makeDeployed;
		dontAskForConfirmationWhenQuitting;
		setProgressBarSizeAndPosition
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> doRaiseWarningForMissingChangesOrSourcesFiles [
	PharoFilesOpener default setInformAboutReadOnlyChanges.
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> dontAskForConfirmationWhenQuitting [
	"self flag: 'TODO'."
	"Since UserManager is now over, there is no clean way to avoid warning when we juast ask to quit the image. More general, there should be a way to have an image in read/only mode"
	Save := false
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> dontRaiseWarningForMissingChangesOrSourcesFiles [
	PharoFilesOpener default unsetInformAboutReadOnlyChanges.
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> initialize [
	Save := false
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> initializeLibgit [
	LGitLibrary uniqueInstance initializeLibGit2
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> isDeployed [

	^ NTSpApplication isDeployed
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> launcherStartUp [

	self isDeployed ifFalse: [ ^ self ].
	
	Smalltalk isInteractiveGraphic
		ifTrue: [ self closeWindowsAndOpenLauncher ]
		ifFalse: [ NTSpApplication default ]
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> launcherStartUpPriority [
	^ 300
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> makeDeployed [

	NTSpApplication beDeployed
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> makeUndeployed [

	NTSpApplication beUndeployed
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> openLauncher [
	NTSpApplication openFull
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> quitSession [
	"self flag: 'TODO'."
	"Since UserManager is now over, there is no clean way to avoid warning when we juast ask to quit the image. More general, there should be a way to have an image in read/only mode"
	Save 
		ifTrue: [Smalltalk snapshot: true andQuit: true] 
		ifFalse: [Smalltalk snapshot: false andQuit: true]
 
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> removeAllMorphs [ 
	" Don't keep unnecessary stuff.
	  Also there is a bug popping with FT2 when trying to send #changed to the MenuBar. Removing morphs will workaround this problem"
	World removeAllMorphs
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> setProgressBarSizeAndPosition [
	"increase size and reposition progress bar to the middle of screen to make it more visible"
	SystemProgressMorph uniqueInstance
		minWidth: 600;
		minHeight: 50;
		layoutInset: 30 @ 20;
		position: 150 @ 200	
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> settingsOn: aBuilder [
	<systemsettings>
	<pharoLauncherSettings>
	(aBuilder setting: #developmentEnvironmentEnabled) 
		parent: #tnt;
		target: self;
		default: false;
		order: 60;
		label: 'Enable development environment';
		description: 'Missing a feature?  Hey come join in!  Add your custom feature.
When enabled, exits the Launcher application into the Pharo development environment.
When disabled, closes all windows and locks Launcher as the only running application. '.
]

{ #category : 'as yet unclassified' }
NTDeploymentScript class >> undoAll [
	self
		activateStartupActions;
		doRaiseWarningForMissingChangesOrSourcesFiles;
		activateDeprecationWarnings;
		activateLostChangesDetector;
		deactivateErrorCatching;
		makeUndeployed;
		askForConfirmationWhenQuitting;
		initializeLibgit
]
